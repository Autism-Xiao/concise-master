import type { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * PostgreSQL 基线标记。
 *
 * PG 库表结构由实体一次性 schema:sync 建立（见 scripts/pg-bootstrap.mjs），
 * 种子数据由 scripts/copy-mysql-to-pg.mjs 从 MySQL 同步。此迁移只用于登记基线，
 * 后续增量迁移照常用 typeorm migration:generate 生成到本目录。
 */
export class Migration1794080000000 implements MigrationInterface {
  name = 'Migration1794080000000'

  public async up(_queryRunner: QueryRunner): Promise<void> {
    // no-op：基线已由实体同步建立
  }

  public async down(_queryRunner: QueryRunner): Promise<void> {
    // no-op
  }
}
