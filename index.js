import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '../views/Dashboard.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: Dashboard,
      meta: { title: '主界面' },
    },
    {
      path: '/users',
      name: 'users',
      component: () => import('../views/UserManagement.vue'),
      meta: { title: '用户管理' },
    },
    {
      path: '/experts',
      name: 'experts',
      component: () => import('../views/ExpertManagement.vue'),
      meta: { title: '专家管理' },
    },
    {
      path: '/tags',
      name: 'tags',
      component: () => import('../views/TagManagement.vue'),
      meta: { title: '标签管理' },
    },
  ],
})

export default router
