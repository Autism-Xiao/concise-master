import type { MigrationInterface, QueryRunner } from 'typeorm'

/**
 * PG 下 sys_message.id 是 uuid，而 sys_message_user.message_id 是 varchar，
 * 关联查询（未读数等）会报 `operator does not exist: uuid = character varying`。
 * 统一改为 uuid。当前两表通常为空；若已有数据，必须是合法 UUID 才能转换。
 */
export class Migration1794080000003 implements MigrationInterface {
  name = 'Migration1794080000003'

  public async up(queryRunner: QueryRunner): Promise<void> {
    const rows = await queryRunner.query(
      `SELECT data_type FROM information_schema.columns
       WHERE table_schema = 'public' AND table_name = 'sys_message_user' AND column_name = 'message_id'`
    )
    if (!rows.length || rows[0].data_type === 'uuid') return
    await queryRunner.query(`ALTER TABLE "sys_message_user" ALTER COLUMN "message_id" TYPE uuid USING "message_id"::uuid`)
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const rows = await queryRunner.query(
      `SELECT data_type FROM information_schema.columns
       WHERE table_schema = 'public' AND table_name = 'sys_message_user' AND column_name = 'message_id'`
    )
    if (!rows.length || rows[0].data_type !== 'uuid') return
    await queryRunner.query(`ALTER TABLE "sys_message_user" ALTER COLUMN "message_id" TYPE varchar(64) USING "message_id"::text`)
  }
}
