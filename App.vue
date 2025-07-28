<template>
  <div id="app">
    <el-container class="layout-container">
      <!-- 侧边栏 -->
      <el-aside class="sidebar" :width="sidebarWidth">
        <div class="logo">
          <img src="@/assets/logo.svg" alt="Logo" v-if="!isCollapsed" />
          <span v-if="!isCollapsed" class="logo-text">医疗专家管理系统</span>
        </div>

        <el-menu
          :default-active="$route.path"
          class="sidebar-menu"
          :collapse="isCollapsed"
          router
          background-color="#304156"
          text-color="#bfcbd9"
          active-text-color="#409eff"
        >
          <el-menu-item index="/">
            <el-icon><House /></el-icon>
            <span>主界面</span>
          </el-menu-item>
          <el-menu-item index="/users">
            <el-icon><Avatar /></el-icon>
            <span>用户管理</span>
          </el-menu-item>
          <el-menu-item index="/experts">
            <el-icon><User /></el-icon>
            <span>专家管理</span>
          </el-menu-item>
          <el-menu-item index="/tags">
            <el-icon><Collection /></el-icon>
            <span>标签管理</span>
          </el-menu-item>
        </el-menu>
      </el-aside>

      <el-container class="main-container">
        <!-- 头部 -->
        <el-header class="header">
          <div class="header-content">
            <div class="header-left">
              <!-- 在模板中保持使用 text 类型 -->
              <el-button
                text
                :icon="isCollapsed ? Expand : Fold"
                @click="toggleSidebar"
                class="collapse-btn"
              />
              <el-button text :icon="Bell" class="header-btn" />
              <h2 class="page-title">{{ getPageTitle() }}</h2>
            </div>

            <div class="header-right">
              <el-badge :value="5" class="notification-badge">
                <el-button text :icon="Bell" class="header-btn" />
              </el-badge>

              <el-dropdown>
                <span class="user-info">
                  <el-avatar size="small" class="user-avatar">
                    <el-icon><UserFilled /></el-icon>
                  </el-avatar>
                  <span v-if="!isCollapsed" class="username">管理员</span>
                  <el-icon class="el-icon--right"><ArrowDown /></el-icon>
                </span>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item :icon="User">个人设置</el-dropdown-item>
                    <el-dropdown-item :icon="Lock">修改密码</el-dropdown-item>
                    <el-dropdown-item divided :icon="SwitchButton">退出登录</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </div>
        </el-header>

        <!-- 主要内容 -->
        <el-main class="main-content">
          <router-view v-slot="{ Component }">
            <transition name="page" mode="out-in">
              <component :is="Component" />
            </transition>
          </router-view>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import {
  House,
  User,
  Avatar,
  Collection,
  UserFilled,
  ArrowDown,
  Bell,
  Lock,
  SwitchButton,
  Expand,
  Fold,
} from '@element-plus/icons-vue'

export default {
  name: 'App',
  components: {
    House,
    User,
    Avatar,
    Collection,
    UserFilled,
    ArrowDown,
    Bell,
    Lock,
    SwitchButton,
    Expand,
    Fold,
  },
  setup() {
    const route = useRoute()
    // 统一使用一个变量名
    const isCollapsed = ref(false)

    const sidebarWidth = computed(() => {
      return isCollapsed.value ? '64px' : '250px'
    })

    // 修复：使用正确的变量名
    const toggleSidebar = () => {
      isCollapsed.value = !isCollapsed.value
    }

    const getPageTitle = () => {
      const titles = {
        '/': '主界面',
        '/users': '用户管理',
        '/experts': '专家管理',
        '/tags': '标签管理',
      }
      return titles[route.path] || '医疗专家管理系统'
    }

    // 返回所有在模板中使用的变量和组件
    return {
      isCollapsed,
      sidebarWidth,
      toggleSidebar,
      getPageTitle,
      // 返回所有图标组件
      House,
      User,
      Avatar,
      Collection,
      UserFilled,
      ArrowDown,
      Bell,
      Lock,
      SwitchButton,
      Expand,
      Fold,
    }
  },
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

/* 修复根容器 */
#app {
  font-family:
    'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', '微软雅黑',
    Arial, sans-serif;
  height: 100vh;
  /* 移除 overflow: hidden，允许内容正常显示 */
  overflow: visible;
  background-color: #f0f2f5;
}

/* 优化布局容器 */
.layout-container {
  height: 100vh;
  transition: all 0.3s ease;
  /* 明确声明为flex布局 */
  display: flex;
  flex-direction: row;
}

/* 侧边栏优化 */
.sidebar {
  background: linear-gradient(180deg, #304156 0%, #2c3e50 100%);
  overflow: hidden;
  transition: width 0.3s ease;
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
  /* 防止侧边栏收缩 */
  flex-shrink: 0;
  /* 确保在全屏时高度正确 */
  height: 100vh;
}

.sidebar.collapsed {
  width: 64px !important;
}

/* 主容器区域优化 */
.main-container {
  transition: all 0.3s ease;
  /* 占据剩余空间 */
  flex: 1;
  /* 防止内容溢出 */
  min-width: 0;
  display: flex;
  flex-direction: column;
}

/* 头部区域 */
.header {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-bottom: 1px solid #e4e7ed;
  padding: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  /* 固定高度 */
  height: 60px;
  flex-shrink: 0;
}

/* 主内容区域关键修复 */
.main-content {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  /* 占据剩余空间 */
  flex: 1;
  padding: 20px;
  /* 允许垂直滚动 */
  overflow-y: auto;
  overflow-x: hidden;
  /* 防止flex子元素宽度溢出的关键设置 */
  min-width: 0;
  /* 确保最小高度 */
  min-height: 0;
}

/* Logo区域 */
.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-bottom: 1px solid #1f2d3d;
  position: relative;
  overflow: hidden;
  flex-shrink: 0;
}

/* 菜单区域 */
.sidebar-menu {
  border: none;
  /* 动态计算高度，减去logo高度 */
  height: calc(100vh - 60px);
  background: transparent !important;
  overflow-y: auto;
}

/* 头部内容布局 */
.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  padding: 0 20px;
  /* 防止内容溢出 */
  min-width: 0;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
  /* 防止收缩 */
  flex-shrink: 0;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 15px;
  /* 防止收缩 */
  flex-shrink: 0;
}

/* 页面标题 */
.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  /* 防止文字换行 */
  white-space: nowrap;
  /* 允许文字溢出时显示省略号 */
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}

/* 响应式设计优化 */
@media (max-width: 1200px) {
  .main-content {
    padding: 15px;
  }

  .page-title {
    font-size: 16px;
    max-width: 150px;
  }
}

@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    z-index: 1000;
    height: 100vh;
    /* 移动端时完全隐藏或显示 */
    transform: translateX(-100%);
    transition: transform 0.3s ease;
  }

  .sidebar.show {
    transform: translateX(0);
  }

  .main-container {
    margin-left: 0;
    width: 100%;
  }

  .header-content {
    padding: 0 15px;
  }

  .page-title {
    font-size: 14px;
    max-width: 120px;
  }

  .main-content {
    padding: 10px;
  }
}

@media (max-width: 480px) {
  .header-content {
    padding: 0 10px;
    gap: 10px;
  }

  .header-left {
    gap: 10px;
  }

  .header-right {
    gap: 8px;
  }

  .main-content {
    padding: 8px;
  }

  .username {
    display: none;
  }

  .page-title {
    display: none;
  }
}

/* 全屏模式特殊优化 */
@media (min-width: 1920px) {
  .main-content {
    padding: 30px;
    max-width: none;
  }

  .header-content {
    padding: 0 30px;
  }
}

/* 动画效果保持不变 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.page-enter-active,
.page-leave-active {
  transition: all 0.3s ease;
}

.page-enter-from {
  opacity: 0;
  transform: translateX(20px);
}

.page-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}

.logo h2 {
  font-size: 16px;
  font-weight: 600;
  white-space: nowrap;
}

.logo-mini {
  font-size: 14px !important;
}

.sidebar-menu {
  border: none;
  height: calc(100vh - 60px);
  background: transparent !important;
}

.sidebar-menu .el-menu-item {
  height: 50px;
  line-height: 50px;
  transition: all 0.3s ease;
  border-radius: 0 25px 25px 0;
  margin: 2px 8px 2px 0;
}

.sidebar-menu .el-menu-item:hover {
  background-color: rgba(64, 158, 255, 0.1) !important;
  transform: translateX(5px);
}

.sidebar-menu .el-menu-item.is-active {
  background: linear-gradient(135deg, #409eff 0%, #36a3f7 100%) !important;
  color: white !important;
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
}

.main-container {
  transition: all 0.3s ease;
}

.header {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-bottom: 1px solid #e4e7ed;
  padding: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  padding: 0 20px;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 15px;
}

.sidebar-toggle {
  font-size: 18px;
  color: #606266;
  transition: all 0.3s ease;
}

.sidebar-toggle:hover {
  color: #409eff;
  transform: scale(1.1);
}

.page-title {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 15px;
}

.notification-badge {
  cursor: pointer;
}

.header-btn {
  font-size: 18px;
  color: #606266;
  transition: all 0.3s ease;
}

.header-btn:hover {
  color: #409eff;
  transform: scale(1.1);
}

.user-info {
  display: flex;
  align-items: center;
  cursor: pointer;
  color: #606266;
  transition: all 0.3s ease;
  padding: 8px 12px;
  border-radius: 20px;
  gap: 8px;
}

.user-info:hover {
  background-color: #f5f7fa;
  color: #409eff;
}

.user-avatar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.username {
  font-weight: 500;
}

.main-content {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  min-height: calc(100vh - 60px);
}

/* 动画效果 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.page-enter-active,
.page-leave-active {
  transition: all 0.3s ease;
}

.page-enter-from {
  opacity: 0;
  transform: translateX(20px);
}

.page-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}
</style>

## 可能的问题原因 1. **侧边栏展开/收起状态问题**：侧边栏可能占用了过多空间 2.
**CSS布局问题**：主内容区域的样式可能有问题 3. **Element
Plus容器组件配置问题**：`el-container`、`el-main` 等组件的配置可能不正确 4.
**响应式布局问题**：在当前屏幕尺寸下布局可能有问题 ## 建议的解决方案 ### 1. 检查侧边栏状态 首先检查
`App.vue` 中侧边栏的展开/收起状态，确保主内容区域有足够的空间:
