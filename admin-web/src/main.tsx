import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { RouterProvider, createRouter } from '@tanstack/react-router'
import { Provider } from 'react-redux'
import { ErrorBoundary } from '@/components/error-boundary'
import { routeTree } from './routeTree.gen'
import { initRealtime } from './lib/realtime'
import { store } from '@/stores'
import './index.css'

const router = createRouter({ routeTree })

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}

// WebSocket 推送生命周期：内部跟随登录态自动连/断
initRealtime()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Provider store={store}>
      <ErrorBoundary title="应用启动失败">
        <RouterProvider router={router} />
      </ErrorBoundary>
    </Provider>
  </StrictMode>
)
