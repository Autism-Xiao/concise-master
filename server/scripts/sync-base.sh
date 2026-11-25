#!/usr/bin/env bash
# sync-base.sh — 把底座（concise-master 单仓）的更新同步到派生项目
# 单仓双目录：前端 admin-web/ + 后端 server/，一条 upstream 线一次 merge 全部同步。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

DEFAULT_BASE_URL="https://github.com/Autism-Xiao/concise-master.git"
BASE_URL="${BASE_URL:-${DEFAULT_BASE_URL}}"
BASE_BRANCH="${BASE_BRANCH:-main}"
MODE="sync"
DRY_RUN=0
NO_PUSH=0
TARGET_DIR=""

usage() {
  cat <<'EOF'
用法: scripts/sync-base.sh [选项] [派生项目根目录]

把底座（单仓：admin-web/ + server/）的更新同步到 fork 出来的项目。
前后端在同一仓库，一次 fetch/merge 即可全部同步。

选项:
  --init               初始化 upstream（新项目 clone 后只跑一次）
  --check              只检查落后多少提交，不修改工作区
  --dry-run            只打印将要执行的 git 命令
  --no-push            合并后不自动 push 到 origin
  --base URL           底座仓库地址（默认 BASE_URL 环境变量）
  --branch NAME        底座分支，默认 main
  -h, --help           显示帮助

参数:
  派生项目根目录（默认脚本所在的底座仓库根，即当前仓库）

环境变量:
  BASE_URL, BASE_BRANCH

示例:
  # 新项目 clone 后，在项目根跑一次
  cd my-project
  bash server/scripts/sync-base.sh --init

  # 日常同步（在项目根运行，自动同步前后端）
  bash server/scripts/sync-base.sh --check
  bash server/scripts/sync-base.sh --no-push
  bash server/scripts/sync-base.sh
EOF
}

log() { printf '%s\n' "$*"; }

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '  [dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

init_repo() {
  local dir="$1"
  local origin_url upstream_url
  origin_url="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
  upstream_url="$(git -C "$dir" remote get-url upstream 2>/dev/null || true)"

  log "初始化 upstream @ ${dir}"
  if [[ -n "$upstream_url" ]]; then
    log "  upstream 已存在: ${upstream_url}"
    [[ "$upstream_url" == "$BASE_URL" ]] || log "  注意：与底座地址 ${BASE_URL} 不一致"
    return 0
  fi

  if [[ "$origin_url" == "$BASE_URL" ]]; then
    run git -C "$dir" remote rename origin upstream
    log "  已把原 origin（底座）改名为 upstream。"
    log "  下一步: git -C '${dir}' remote add origin <你的新仓库地址>"
    log "  然后:   git -C '${dir}' push -u origin ${BASE_BRANCH}"
  else
    run git -C "$dir" remote add upstream "$BASE_URL"
    log "  已添加 upstream: ${BASE_URL}"
    [[ -n "$origin_url" ]] || log "  警告：当前仓库没有 origin，请先添加你的新仓库远程。"
  fi
}

analyze_conflicts() {
  local conflicts="$1"
  local admin_patterns=(admin-web/src/components/ admin-web/src/hooks/ admin-web/src/lib/ admin-web/src/stores/ admin-web/src/config/ admin-web/src/context/ admin-web/src/routes/ admin-web/src/assets/ admin-web/src/index.css admin-web/src/main.tsx admin-web/package.json admin-web/vite.config. admin-web/tsconfig admin-web/index.html admin-web/public/)
  local server_patterns=(server/src/shared/ server/src/common/ server/src/config/ server/src/constants/ server/src/global/ server/src/helper/ server/src/utils/ server/src/migrations/ server/src/main.ts server/src/app.module.ts server/package.json server/nest-cli.json server/tsconfig server/Dockerfile server/docker-compose server/deploy/ server/scripts/)
  local base_count=0 biz_count=0 line pat
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    for pat in "${admin_patterns[@]}" "${server_patterns[@]}"; do
      if [[ "$line" == "$pat"* ]]; then
        base_count=$((base_count + 1))
        continue 2
      fi
    done
    biz_count=$((biz_count + 1))
  done <<< "$conflicts"
  log "  冲突分类：底座层 ${base_count} 个，业务层 ${biz_count} 个"
  if [[ "$biz_count" -gt 0 ]]; then
    log "  业务层冲突说明你改过底座文件。建议把通用改动提回底座仓库，而不是留在项目里。"
  fi
}

sync_repo() {
  local dir="$1"
  local upstream_url behind conflicts origin_url
  log "同步 ${dir}"

  upstream_url="$(git -C "$dir" remote get-url upstream 2>/dev/null || true)"
  if [[ -z "$upstream_url" ]]; then
    log "  跳过：未配置 upstream。先运行 bash server/scripts/sync-base.sh --init"
    return 1
  fi
  if [[ -n "$(git -C "$dir" status --porcelain)" ]]; then
    log "  跳过：工作区有未提交改动，请先 commit 或 stash。"
    return 1
  fi

  run git -C "$dir" fetch upstream --prune
  behind="$(git -C "$dir" rev-list --count "HEAD..upstream/${BASE_BRANCH}" 2>/dev/null || printf '?')"
  log "  落后底座 ${behind} 个提交（前端 + 后端一起）"

  if [[ "$MODE" == "check" || "$behind" == "0" ]]; then
    [[ "$MODE" == "check" ]] || log "  已是最新"
    return 0
  fi

  if ! run git -C "$dir" merge --no-edit "upstream/${BASE_BRANCH}"; then
    log "  合并冲突，文件如下："
    conflicts="$(git -C "$dir" diff --name-only --diff-filter=U)"
    printf '%s\n' "$conflicts" | sed 's/^/    /'
    analyze_conflicts "$conflicts"
    log "  处理：解决冲突后 git add + git commit；或 git merge --abort 撤销本次同步。"
    return 2
  fi

  log "  合并成功（前端 + 后端）"
  if [[ "$NO_PUSH" -eq 0 ]]; then
    origin_url="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
    if [[ -n "$origin_url" ]]; then
      run git -C "$dir" push origin HEAD
    else
      log "  警告：未配置 origin，跳过 push"
    fi
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --init) MODE="init"; shift ;;
      --check) MODE="check"; shift ;;
      --dry-run) DRY_RUN=1; shift ;;
      --no-push) NO_PUSH=1; shift ;;
      --base) BASE_URL="${2:?缺少地址}"; shift 2 ;;
      --branch) BASE_BRANCH="${2:?缺少分支名}"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      -*) log "未知选项: $1"; usage; exit 1 ;;
      *) TARGET_DIR="$1"; shift ;;
    esac
  done

  [[ -n "$TARGET_DIR" ]] || TARGET_DIR="$REPO_ROOT"

  if [[ ! -d "$TARGET_DIR" ]]; then log "目录不存在: ${TARGET_DIR}"; exit 1; fi
  if [[ ! -e "$TARGET_DIR/.git" ]]; then log "不是 Git 仓库: ${TARGET_DIR}"; exit 1; fi

  if [[ "$MODE" == "init" ]]; then
    init_repo "$TARGET_DIR"
  else
    sync_repo "$TARGET_DIR"
  fi
}

main "$@"
