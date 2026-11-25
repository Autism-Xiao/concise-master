import { BadRequestException } from '@nestjs/common'

import { readXlsxTable, type XlsxTable } from '../../utils/xlsx.util'

/**
 * 导入文件读取公共件
 *
 * 各模块的导入前处理完全一样：校验有没有文件 → 解析 xlsx → 统一报错文案。
 * 之前每个控制器都抄一遍这段分支，文案还各自微调；收敛到这里后，新增模块只写列映射与业务校验。
 *
 * 约定（与用户管理一致）：
 * - 仅支持 .xlsx，可带大标题与填写说明（靠 headerKeys 定位表头）
 * - 返回 { rows, headerRow }，交给模块自己的 Service 做列定位与逐行校验
 */

/** 读取选项 */
export interface ReadImportFileOptions {
  /** 表头关键字：用于跳过模板的大标题/说明行（如 ['登录账号', '账号']） */
  headerKeys: string[]
}

/** 未选文件时的统一提示 */
export const IMPORT_FILE_REQUIRED = '未接收到文件，请选择 Excel 后重试'

/**
 * 读取上传的导入文件
 *
 * @throws BadRequestException 未选文件 / 扩展名不支持
 */
export async function readImportFile(file: Express.Multer.File | undefined, options: ReadImportFileOptions): Promise<XlsxTable> {
  if (!file) {
    throw new BadRequestException(IMPORT_FILE_REQUIRED)
  }
  const filename = file.originalname ?? ''

  if (/\.xlsx$/i.test(filename)) {
    return readXlsxTable(file.buffer, { headerKeys: options.headerKeys })
  }

  throw new BadRequestException('仅支持 .xlsx 文件，请下载模板填写后导入')
}
