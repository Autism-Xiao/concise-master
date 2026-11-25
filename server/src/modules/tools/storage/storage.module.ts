import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'

import { StorageEntity } from './storage.entity'
import { StorageService } from './storage.service'

/** 旧版附件存储模块：tool_storage 记录的读写，UploadModule 依赖它的 StorageService */
@Module({
  imports: [TypeOrmModule.forFeature([StorageEntity])],
  providers: [StorageService],
  exports: [StorageService]
})
export class StorageModule {}
