# Concise 底座

通用后台管理系统底座：前端 + 后端同仓管理，配套 MySQL / PostgreSQL / Redis。可作为新项目的起点 fork 使用。

## 目录结构

```
concise-master/
├── admin-web/       前端：React 19 + Vite + TypeScript + Redux Toolkit + shadcn/ui
├── server/          后端：稳定职责名，当前实现 NestJS + TypeORM + MySQL/PG + Redis
│   ├── src/         业务与底座模块
│   ├── scripts/     运维脚本（同步、迁移、冒烟、备份恢复）
│   ├── deploy/sql/  数据库备份产物目录（含数据，不入库）
│   └── docs/        开发记录与审计报告
├── doc/             产品文档：使用手册、功能清单、优化分析
└── README.md
```

**命名约定**：目录用职责名，不写技术栈。`server/` 当前是 NestJS，未来若用 Go 重构，只替换该目录内容，对外路径（前端 baseURL、部署脚本、CI、文档引用）保持不变。当前技术栈写在 [`server/README.md`](./server/README.md)。

## 技术栈

| 目录 | 技术 |
| --- | --- |
| `admin-web/` | React 19、TypeScript 6、Vite 8、Redux Toolkit、TanStack Router/Table、shadcn/ui（Tailwind 4 + Base UI）、recharts |
| `server/` | NestJS 12、TypeORM、MySQL 8.4 / PostgreSQL 16、Redis、Jest、argon2 |

## 快速开始

```bash
# 1. 后端（先起，前端数据全部来自 API）
cd server
cp .env.example .env       # 按需修改 DB_TYPE / DB_HOST / DB_PASSWORD 等
pnpm install
pnpm start:dev             # 默认 http://127.0.0.1:3000/api/v1

# 2. 前端
cd ../admin-web
cp .env.example .env       # 若存在；否则用默认 vite 代理
pnpm install
pnpm dev                   # http://localhost:5173
```

浏览器打开 http://localhost:5173 ，用后端下发的账号登录。角色与菜单由 `/api/v1/auth/permissions` 返回，前端不内置演示账号。

**双方言配置**：`DB_TYPE=mysql|postgres`。PG 需显式设置 `PG_PORT=5432`、`PG_USERNAME`、`PG_PASSWORD`，避免误连 MySQL 的 3306。详见 [`server/.env.example`](./server/.env.example)。

## 底座复用与新项目

本仓库作为单一底座，新项目直接从本仓库 fork：

```bash
git clone https://github.com/Autism-Xiao/concise-master.git my-project
cd my-project
git remote rename origin upstream
git remote add origin https://github.com/<你的账号>/my-project.git
git push -u origin main
```

以后底座更新，一条命令同步前后端（单仓，不再需要分别同步两个仓库）：

```bash
bash server/scripts/sync-base.sh --check     # 先看落后多少提交
bash server/scripts/sync-base.sh --no-push   # 合并但不推，验证后手动 push
bash server/scripts/sync-base.sh             # 合并并自动 push
```

同步脚本详细说明见 [`server/docs/底座复用与同步约定.md`](./server/docs/底座复用与同步约定.md)。

## 分层纪律（避免同步冲突）

- **底座层**（通用能力）：鉴权、RBAC、租户、数据库方言、通用组件与工具。要改就改在底座并提交，所有项目一起同步，**不要在派生项目里各改一遍**。
- **业务层**（各项目独有）：后端放 `server/src/modules/<业务>/`，前端放 `admin-web/src/features/<业务>/`。底座永不触碰这些目录。
- 守住这条边界，`git merge upstream/main` 几乎不会冲突。

## 文档

- [从零使用手册 · 功能走查](./doc/从零使用手册-功能走查.md) — 登录后按菜单走完全部功能
- [项目功能点清单](./doc/项目功能点清单.md)
- [使用说明](./doc/使用说明.md)
- [底座复用与同步约定](./server/docs/底座复用与同步约定.md)
- [底座代码审计报告](./server/docs/底座代码审计报告-2026-11-25.md)

## 仓库历史

本仓由原 `concise-admin`（前端）与 `concise-server-node`（后端）合并而来，采用干净初始提交，不携带原两仓历史。原仓库保留作归档，不再更新。
