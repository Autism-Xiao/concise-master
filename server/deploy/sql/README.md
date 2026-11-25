# SQL 备份目录

本目录存放数据库备份产物（`node scripts/dump-sql.mjs --out-dir=deploy/sql` 生成），**含真实数据，不入库**。

`.gitignore` 已排除 `*.sql`，仅保留本说明与 `.gitkeep`。

需要初始化数据库时，使用 `scripts/pg-bootstrap.mjs` / `scripts/restore-sql.mjs` 从外部备份恢复；结构迁移走 `src/migrations/`。
