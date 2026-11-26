import { createFileRoute } from '@tanstack/react-router'
import { DataRulePage } from '@/features/system/data-rule'

export const Route = createFileRoute('/_authenticated/system/data-rule')({
  component: DataRulePage
})
