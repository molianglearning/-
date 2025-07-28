<template>
  <div class="dashboard">
    <!-- 欢迎横幅 -->
    <div class="welcome-banner">
      <div class="welcome-content">
        <h1 class="welcome-title">欢迎回来，管理员！</h1>
        <p class="welcome-subtitle">今天是 {{ currentDate }}，祝您工作愉快</p>
      </div>
      <div class="welcome-illustration">
        <el-icon size="80" color="#409eff"><TrendCharts /></el-icon>
      </div>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="24" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6" v-for="(stat, index) in statsData" :key="index">
        <div class="stats-card" @click="navigateToPage(stat.route)">
          <div class="stats-content">
            <div class="stats-icon" :class="stat.iconClass">
              <el-icon :size="32"><component :is="stat.icon" /></el-icon>
            </div>
            <div class="stats-info">
              <div class="stats-number" :data-target="stat.value">{{ animatedNumbers[index] }}</div>
              <div class="stats-label">{{ stat.label }}</div>
              <div class="stats-trend" :class="stat.trend > 0 ? 'positive' : 'negative'">
                <el-icon><component :is="stat.trend > 0 ? 'TrendCharts' : 'Bottom'" /></el-icon>
                {{ Math.abs(stat.trend) }}%
              </div>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 图表和快速操作 -->
    <el-row :gutter="24" class="content-row">
      <!-- 数据图表 -->
      <el-col :xs="24" :lg="16">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <span
                ><el-icon><TrendCharts /></el-icon> 数据趋势</span
              >
              <el-radio-group v-model="chartPeriod" size="small">
                <el-radio-button value="week">本周</el-radio-button>
                <el-radio-button value="month">本月</el-radio-button>
                <el-radio-button value="year">本年</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div class="chart-container">
            <div class="chart-placeholder">
              <el-icon size="60" color="#c0c4cc"><TrendCharts /></el-icon>
              <p>图表数据加载中...</p>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 快速操作 -->
      <el-col :xs="24" :lg="8">
        <el-card class="quick-actions-card">
          <template #header>
            <div class="card-header">
              <span
                ><el-icon><Operation /></el-icon> 快速操作</span
              >
            </div>
          </template>
          <div class="quick-action-grid">
            <div
              class="action-item"
              v-for="action in quickActions"
              :key="action.name"
              @click="handleQuickAction(action)"
            >
              <div class="action-icon" :class="action.colorClass">
                <el-icon :size="24"><component :is="action.icon" /></el-icon>
              </div>
              <span class="action-label">{{ action.label }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最近活动和通知 -->
    <el-row :gutter="24" class="bottom-row">
      <!-- 最近活动 -->
      <el-col :xs="24" :lg="12">
        <el-card class="activity-card">
          <template #header>
            <div class="card-header">
              <span
                ><el-icon><Clock /></el-icon> 最近活动</span
              >
              <el-link type="primary" underline="never">查看全部</el-link>
            </div>
          </template>
          <div class="activity-list">
            <div
              class="activity-item"
              v-for="(activity, index) in activities"
              :key="index"
              :style="{ animationDelay: index * 0.1 + 's' }"
            >
              <div class="activity-avatar">
                <el-avatar :size="32" :src="activity.avatar">
                  <el-icon><component :is="activity.icon" /></el-icon>
                </el-avatar>
              </div>
              <div class="activity-content">
                <div class="activity-title">{{ activity.title }}</div>
                <div class="activity-description">{{ activity.description }}</div>
                <div class="activity-time">{{ activity.time }}</div>
              </div>
              <div class="activity-status" :class="activity.status">
                <el-tag :type="getStatusType(activity.status)" size="small">
                  {{ getStatusText(activity.status) }}
                </el-tag>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 系统通知 -->
      <el-col :xs="24" :lg="12">
        <el-card class="notification-card">
          <template #header>
            <div class="card-header">
              <span
                ><el-icon><Bell /></el-icon> 系统通知</span
              >
              <el-badge :value="unreadCount" :max="99">
                <el-button size="small" text>标记已读</el-button>
              </el-badge>
            </div>
          </template>
          <div class="notification-list">
            <div
              class="notification-item"
              v-for="(notification, index) in notifications"
              :key="index"
              :class="{ unread: !notification.read }"
            >
              <div class="notification-icon" :class="notification.type">
                <el-icon><component :is="getNotificationIcon(notification.type)" /></el-icon>
              </div>
              <div class="notification-content">
                <div class="notification-title">{{ notification.title }}</div>
                <div class="notification-message">{{ notification.message }}</div>
                <div class="notification-time">{{ notification.time }}</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  User,
  Avatar,
  Document,
  Collection,
  TrendCharts,
  Operation,
  Clock,
  Bell,
  Plus,
  Setting,
  DataAnalysis,
  Bottom,
  Warning,
  SuccessFilled,
  InfoFilled,
} from '@element-plus/icons-vue'

export default {
  name: 'AdminDashboard',
  components: {
    User,
    Avatar,
    Document,
    Collection,
    TrendCharts,
    Operation,
    Clock,
    Bell,
    Plus,
    Setting,
    DataAnalysis,
    Bottom,
    Warning,
    SuccessFilled,
    InfoFilled,
  },
  setup() {
    const router = useRouter()
    const chartPeriod = ref('month')
    const animatedNumbers = ref([0, 0, 0, 0])

    // 当前日期
    const currentDate = computed(() => {
      return new Date().toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        weekday: 'long',
      })
    })

    // 统计数据
    const statsData = reactive([
      {
        icon: 'User',
        iconClass: 'user-icon',
        label: '总用户数',
        value: 1234,
        trend: 12.5,
        route: '/users',
      },
      {
        icon: 'Avatar',
        iconClass: 'expert-icon',
        label: '专家总数',
        value: 89,
        trend: 8.2,
        route: '/experts',
      },
      {
        icon: 'Document',
        iconClass: 'subscription-icon',
        label: '活跃订阅',
        value: 567,
        trend: -2.1,
        route: '/subscriptions',
      },
      {
        icon: 'Collection',
        iconClass: 'tag-icon',
        label: '专业标签',
        value: 23,
        trend: 15.3,
        route: '/tags',
      },
    ])

    // 快速操作
    const quickActions = reactive([
      {
        name: 'addUser',
        icon: 'Plus',
        label: '添加用户',
        colorClass: 'blue',
        route: '/users',
      },
      {
        name: 'addExpert',
        icon: 'Avatar',
        label: '添加专家',
        colorClass: 'purple',
        route: '/experts',
      },
      {
        name: 'manageTag',
        icon: 'Collection',
        label: '管理标签',
        colorClass: 'green',
        route: '/tags',
      },
      {
        name: 'dataAnalysis',
        icon: 'DataAnalysis',
        label: '数据分析',
        colorClass: 'orange',
        route: '/analytics',
      },
      {
        name: 'systemSetting',
        icon: 'Setting',
        label: '系统设置',
        colorClass: 'gray',
        route: '/settings',
      },
      {
        name: 'backup',
        icon: 'Document',
        label: '数据备份',
        colorClass: 'cyan',
        route: '/backup',
      },
    ])

    // 最近活动
    const activities = reactive([
      {
        icon: 'User',
        avatar: '',
        title: '新用户注册',
        description: '用户 "张三" 完成注册',
        time: '2分钟前',
        status: 'success',
      },
      {
        icon: 'Avatar',
        avatar: '',
        title: '专家信息更新',
        description: '李医生更新了个人资料',
        time: '5分钟前',
        status: 'info',
      },
      {
        icon: 'Document',
        avatar: '',
        title: '新订阅创建',
        description: '心血管科新增3个订阅',
        time: '10分钟前',
        status: 'success',
      },
      {
        icon: 'Warning',
        avatar: '',
        title: '系统警告',
        description: '服务器负载较高',
        time: '15分钟前',
        status: 'warning',
      },
    ])

    // 系统通知
    const notifications = reactive([
      {
        type: 'info',
        title: '系统更新',
        message: '系统将于今晚23:00进行维护更新',
        time: '1小时前',
        read: false,
      },
      {
        type: 'warning',
        title: '存储空间警告',
        message: '数据库存储空间使用率已达85%',
        time: '2小时前',
        read: false,
      },
      {
        type: 'success',
        title: '备份完成',
        message: '数据备份已成功完成',
        time: '3小时前',
        read: true,
      },
    ])

    // 未读通知数量
    const unreadCount = computed(() => {
      return notifications.filter((n) => !n.read).length
    })

    // 数字动画
    const animateNumbers = () => {
      statsData.forEach((stat, index) => {
        let current = 0
        const target = stat.value
        const increment = target / 50
        const timer = setInterval(() => {
          current += increment
          if (current >= target) {
            current = target
            clearInterval(timer)
          }
          animatedNumbers.value[index] = Math.floor(current)
        }, 30)
      })
    }

    // 页面导航
    const navigateToPage = (route) => {
      if (route) {
        router.push(route)
      }
    }

    // 快速操作处理
    const handleQuickAction = (action) => {
      ElMessage.success(`执行操作：${action.label}`)
      if (action.route) {
        router.push(action.route)
      }
    }

    // 获取状态类型
    const getStatusType = (status) => {
      const types = {
        success: 'success',
        warning: 'warning',
        error: 'danger',
        info: 'info',
      }
      return types[status] || 'info'
    }

    // 获取状态文本
    const getStatusText = (status) => {
      const texts = {
        success: '成功',
        warning: '警告',
        error: '错误',
        info: '信息',
      }
      return texts[status] || '未知'
    }

    // 获取通知图标
    const getNotificationIcon = (type) => {
      const icons = {
        info: 'InfoFilled',
        warning: 'Warning',
        success: 'SuccessFilled',
        error: 'Warning',
      }
      return icons[type] || 'InfoFilled'
    }

    // 页面初始化
    onMounted(() => {
      ElMessage.success('欢迎使用医疗专家管理系统')
      setTimeout(() => {
        animateNumbers()
      }, 500)
    })

    return {
      currentDate,
      chartPeriod,
      statsData,
      quickActions,
      activities,
      notifications,
      unreadCount,
      animatedNumbers,
      navigateToPage,
      handleQuickAction,
      getStatusType,
      getStatusText,
      getNotificationIcon,
    }
  },
}
</script>

<style scoped>
.dashboard {
  padding: 0;
  min-height: calc(100vh - 120px);
}

/* 欢迎横幅 */
.welcome-banner {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 32px;
  margin-bottom: 24px;
  color: white;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
  animation: slideInDown 0.6s ease-out;
}

.welcome-title {
  font-size: 28px;
  font-weight: 600;
  margin-bottom: 8px;
}

.welcome-subtitle {
  font-size: 16px;
  opacity: 0.9;
}

.welcome-illustration {
  opacity: 0.8;
}

/* 统计卡片 */
.stats-row {
  margin-bottom: 24px;
}

.stats-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  border: 1px solid #f0f0f0;
  height: 140px;
  animation: fadeInUp 0.6s ease-out;
  animation-fill-mode: both;
}

.stats-card:nth-child(1) {
  animation-delay: 0.1s;
}
.stats-card:nth-child(2) {
  animation-delay: 0.2s;
}
.stats-card:nth-child(3) {
  animation-delay: 0.3s;
}
.stats-card:nth-child(4) {
  animation-delay: 0.4s;
}

.stats-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15);
}

.stats-content {
  display: flex;
  align-items: center;
  height: 100%;
}

.stats-icon {
  width: 64px;
  height: 64px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20px;
  color: white;
  position: relative;
  overflow: hidden;
}

.stats-icon::before {
  content: '';
  position: absolute;
  top: -50%;
  left: -50%;
  width: 200%;
  height: 200%;
  background: linear-gradient(45deg, transparent, rgba(255, 255, 255, 0.1), transparent);
  transform: rotate(45deg);
  transition: all 0.6s;
}

.stats-card:hover .stats-icon::before {
  animation: shimmer 1.5s ease-in-out;
}

.user-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.expert-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.subscription-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.tag-icon {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stats-info {
  flex: 1;
}

.stats-number {
  font-size: 32px;
  font-weight: 700;
  color: #303133;
  margin-bottom: 4px;
  line-height: 1;
}

.stats-label {
  font-size: 14px;
  color: #909399;
  margin-bottom: 8px;
}

.stats-trend {
  display: flex;
  align-items: center;
  font-size: 12px;
  font-weight: 500;
}

.stats-trend.positive {
  color: #67c23a;
}

.stats-trend.negative {
  color: #f56c6c;
}

.stats-trend .el-icon {
  margin-right: 4px;
}

/* 内容行 */
.content-row {
  margin-bottom: 24px;
}

/* 图表卡片 */
.chart-card {
  height: 400px;
  animation: fadeInLeft 0.6s ease-out 0.5s both;
}

.chart-container {
  height: 320px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fafafa;
  border-radius: 8px;
}

.chart-placeholder {
  text-align: center;
  color: #909399;
}

.chart-placeholder p {
  margin-top: 16px;
  font-size: 14px;
}

/* 快速操作卡片 */
.quick-actions-card {
  height: 400px;
  animation: fadeInRight 0.6s ease-out 0.5s both;
}

.quick-action-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  height: 320px;
  align-content: start;
}

.action-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
  border: 2px solid #f0f0f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: white;
  height: 100px;
}

.action-item:hover {
  border-color: #409eff;
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(64, 158, 255, 0.2);
}

.action-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8px;
  color: white;
}

.action-icon.blue {
  background: linear-gradient(135deg, #409eff 0%, #3a8ee6 100%);
}
.action-icon.purple {
  background: linear-gradient(135deg, #9c88ff 0%, #8b5cf6 100%);
}
.action-icon.green {
  background: linear-gradient(135deg, #67c23a 0%, #5daf34 100%);
}
.action-icon.orange {
  background: linear-gradient(135deg, #e6a23c 0%, #d4922f 100%);
}
.action-icon.gray {
  background: linear-gradient(135deg, #909399 0%, #82848a 100%);
}
.action-icon.cyan {
  background: linear-gradient(135deg, #17c0eb 0%, #1ab6e8 100%);
}

.action-label {
  font-size: 13px;
  color: #606266;
  font-weight: 500;
  text-align: center;
}

/* 底部行 */
.bottom-row {
  margin-bottom: 24px;
}

/* 活动卡片 */
.activity-card {
  height: 400px;
  animation: fadeInUp 0.6s ease-out 0.7s both;
}

.activity-list {
  height: 320px;
  overflow-y: auto;
}

.activity-item {
  display: flex;
  align-items: flex-start;
  padding: 16px 0;
  border-bottom: 1px solid #f5f5f5;
  animation: slideInLeft 0.4s ease-out;
  animation-fill-mode: both;
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-avatar {
  margin-right: 12px;
  flex-shrink: 0;
}

.activity-content {
  flex: 1;
  min-width: 0;
}

.activity-title {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.activity-description {
  font-size: 13px;
  color: #606266;
  margin-bottom: 4px;
}

.activity-time {
  font-size: 12px;
  color: #909399;
}

.activity-status {
  flex-shrink: 0;
  margin-left: 12px;
}

/* 通知卡片 */
.notification-card {
  height: 400px;
  animation: fadeInUp 0.6s ease-out 0.8s both;
}

.notification-list {
  height: 320px;
  overflow-y: auto;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  padding: 16px;
  border-radius: 8px;
  margin-bottom: 12px;
  transition: all 0.3s ease;
  border-left: 4px solid transparent;
}

.notification-item.unread {
  background-color: #f0f9ff;
  border-left-color: #409eff;
}

.notification-item:hover {
  background-color: #fafafa;
}

.notification-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 12px;
  flex-shrink: 0;
  color: white;
}

.notification-icon.info {
  background: #409eff;
}
.notification-icon.warning {
  background: #e6a23c;
}
.notification-icon.success {
  background: #67c23a;
}
.notification-icon.error {
  background: #f56c6c;
}

.notification-content {
  flex: 1;
  min-width: 0;
}

.notification-title {
  font-size: 14px;
  font-weight: 500;
  color: #303133;
  margin-bottom: 4px;
}

.notification-message {
  font-size: 13px;
  color: #606266;
  margin-bottom: 4px;
  line-height: 1.4;
}

.notification-time {
  font-size: 12px;
  color: #909399;
}

/* 卡片头部 */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
  color: #303133;
}

.card-header span {
  display: flex;
  align-items: center;
}

.card-header .el-icon {
  margin-right: 8px;
  color: #409eff;
}

/* 动画定义 */
@keyframes slideInDown {
  from {
    opacity: 0;
    transform: translateY(-30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeInLeft {
  from {
    opacity: 0;
    transform: translateX(-30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes fadeInRight {
  from {
    opacity: 0;
    transform: translateX(30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes shimmer {
  0% {
    transform: translateX(-100%) translateY(-100%) rotate(45deg);
  }
  100% {
    transform: translateX(100%) translateY(100%) rotate(45deg);
  }
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .quick-action-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .action-item {
    height: 80px;
    padding: 16px;
  }
}

@media (max-width: 768px) {
  .welcome-banner {
    flex-direction: column;
    text-align: center;
    padding: 24px;
  }

  .welcome-illustration {
    margin-top: 16px;
  }

  .stats-card {
    margin-bottom: 16px;
    height: 120px;
    padding: 20px;
  }

  .stats-number {
    font-size: 24px;
  }

  .chart-card,
  .quick-actions-card,
  .activity-card,
  .notification-card {
    height: auto;
    margin-bottom: 16px;
  }

  .chart-container {
    height: 200px;
  }

  .activity-list,
  .notification-list {
    height: auto;
    max-height: 300px;
  }
}

@media (max-width: 480px) {
  .dashboard {
    padding: 0;
  }

  .welcome-title {
    font-size: 20px;
  }

  .welcome-subtitle {
    font-size: 14px;
  }

  .stats-content {
    flex-direction: column;
    text-align: center;
  }

  .stats-icon {
    margin-right: 0;
    margin-bottom: 12px;
  }

  .quick-action-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
