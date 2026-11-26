import { createFileRoute } from '@tanstack/react-router'
import { GrantPage } from '@/features/system/grant'

export const Route = createFileRoute('/_authenticated/system/grant')({
  component: GrantPage
})
