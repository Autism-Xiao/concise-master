import type { ColumnDef } from '@tanstack/react-table'

/**
 * 多选勾选列（列 id 固定为 select）
 *
 * DataTable 已特判 id=select：表头勾选框置最左、序号列紧跟其后、表体行首渲染勾选框，
 * 页面只要把本列放进 columns 即可，不用关心渲染位置。
 *
 * @param getLabel 每行的无障碍标签文本来源（如标题/姓名/编号），供屏幕阅读器区分勾选的是哪一行
 */
export function selectColumn<TData>(getLabel: (row: TData) => string | number): ColumnDef<TData> {
  return {
    id: 'select',
    header: ({ table }) => (
      <input
        type="checkbox"
        className="accent-primary size-4 cursor-pointer align-middle"
        aria-label="全选本页"
        checked={table.getIsAllPageRowsSelected()}
        ref={el => {
          if (el) el.indeterminate = table.getIsSomePageRowsSelected()
        }}
        onChange={table.getToggleAllPageRowsSelectedHandler()}
      />
    ),
    cell: ({ row }) => (
      <input
        type="checkbox"
        className="accent-primary size-4 cursor-pointer align-middle"
        aria-label={`选择「${getLabel(row.original)}」`}
        checked={row.getIsSelected()}
        disabled={!row.getCanSelect()}
        onChange={row.getToggleSelectedHandler()}
      />
    ),
    enableSorting: false,
    enableHiding: false
  }
}
