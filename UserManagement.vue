<template>
  <div class="user-management">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-left">
        <h1 class="page-title">
          <el-icon class="title-icon"><User /></el-icon>
          用户管理
        </h1>
        <p class="page-description">管理系统中的所有用户信息</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="showAddDialog = true" class="add-btn">
          <el-icon><Plus /></el-icon>
          添加用户
        </el-button>
        <el-button @click="exportUsers" class="export-btn">
          <el-icon><Download /></el-icon>
          导出数据
        </el-button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stats-row">
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card total-users">
          <div class="stat-icon">
            <el-icon><User /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ userStats.total }}</div>
            <div class="stat-label">总用户数</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card active-users">
          <div class="stat-icon">
            <el-icon><UserFilled /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ userStats.active }}</div>
            <div class="stat-label">活跃用户</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card new-users">
          <div class="stat-icon">
            <el-icon><Plus /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ userStats.newToday }}</div>
            <div class="stat-label">今日新增</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="6">
        <div class="stat-card subscription-users">
          <div class="stat-icon">
            <el-icon><Star /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-number">{{ userStats.subscribed }}</div>
            <div class="stat-label">订阅用户</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 搜索筛选 -->
    <el-card class="search-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <el-icon><SearchIcon /></el-icon>
          <span>搜索筛选</span>
          <el-button 
            type="text" 
            size="small"
            @click="toggleSearchExpand" 
            class="expand-btn"
          >
            {{ searchExpanded ? '收起' : '展开' }}
            <el-icon class="el-icon--right">
              <component :is="searchExpanded ? ArrowUp : ArrowDown" />
            </el-icon>
          </el-button>
        </div>
      </template>
      <el-collapse-transition>
        <div v-show="searchExpanded">
          <el-form :inline="true" :model="searchForm" class="search-form">
            <el-row :gutter="20">
              <el-col :xs="24" :sm="12" :md="8" :lg="6">
                <el-form-item label="用户名">
                  <el-input 
                    v-model="searchForm.username" 
                    placeholder="请输入用户名" 
                    clearable 
                    prefix-icon="User"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="12" :md="8" :lg="6">
                <el-form-item label="邮箱">
                  <el-input 
                    v-model="searchForm.email" 
                    placeholder="请输入邮箱" 
                    clearable 
                    prefix-icon="Message"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="12" :md="8" :lg="6">
                <el-form-item label="手机号">
                  <el-input 
                    v-model="searchForm.phone" 
                    placeholder="请输入手机号" 
                    clearable 
                    prefix-icon="Phone"
                  />
                </el-form-item>
              </el-col>
              <el-col :xs="24" :sm="12" :md="8" :lg="6">
                <el-form-item label="状态">
                  <el-select v-model="searchForm.status" placeholder="选择状态" clearable>
                    <el-option label="全部" value="" />
                    <el-option label="活跃" value="active" />
                    <el-option label="禁用" value="disabled" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>
            <el-row>
              <el-col :span="24" class="search-actions">
                <el-button type="primary" @click="searchUsers" :loading="loading">
                  <el-icon><SearchIcon /></el-icon>
                  搜索
                </el-button>
                <el-button @click="resetSearch">
                  <el-icon><Refresh /></el-icon>
                  重置
                </el-button>
              </el-col>
            </el-row>
          </el-form>
        </div>
      </el-collapse-transition>
    </el-card>

    <!-- 用户列表 -->
    <el-card class="table-card" shadow="hover">
      <template #header>
        <div class="card-header">
          <el-icon><List /></el-icon>
          <span>用户列表</span>
          <div class="table-actions">
            <el-button-group>
              <el-button 
                :type="viewMode === 'table' ? 'primary' : ''"
                @click="viewMode = 'table'"
                size="small"
              >
                <el-icon><Grid /></el-icon>
              </el-button>
              <el-button 
                :type="viewMode === 'card' ? 'primary' : ''"
                @click="viewMode = 'card'"
                size="small"
              >
                <el-icon><MenuIcon /></el-icon>
              </el-button>
            </el-button-group>
          </div>
        </div>
      </template>
      
      <!-- 表格视图 -->
      <div v-if="viewMode === 'table'" class="table-view">
        <el-table 
          :data="userList" 
          v-loading="loading" 
          stripe 
          class="user-table"
          @selection-change="handleSelectionChange"
          :default-sort="{prop: 'created_at', order: 'descending'}"
        >
          <el-table-column type="selection" width="55" />
          <el-table-column prop="user_id" label="用户ID" width="80" sortable />
          <el-table-column prop="avatar" label="头像" width="80">
            <template #default="scope">
              <el-avatar :size="40" :src="scope.row.avatar">
                <el-icon><User /></el-icon>
              </el-avatar>
            </template>
          </el-table-column>
          <el-table-column prop="username" label="用户名" width="120" sortable>
            <template #default="scope">
              <div class="user-info-cell">
                <span class="username">{{ scope.row.username }}</span>
                <el-tag v-if="scope.row.is_vip" type="warning" size="small">VIP</el-tag>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="email" label="邮箱" min-width="200" show-overflow-tooltip />
          <el-table-column prop="phone" label="手机号" width="130" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="scope">
              <el-tag 
                :type="scope.row.status === 'active' ? 'success' : 'danger'"
                effect="dark"
              >
                {{ scope.row.status === 'active' ? '活跃' : '禁用' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="created_at" label="注册时间" width="180" sortable>
            <template #default="scope">
              <div class="time-cell">
                <el-icon><Clock /></el-icon>
                {{ formatDate(scope.row.created_at) }}
              </div>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="scope">
              <div class="action-buttons">
                <el-tooltip content="查看详情" placement="top">
                  <el-button size="small" type="primary" @click="viewUser(scope.row)" circle>
                    <el-icon><ViewIcon /></el-icon>
                  </el-button>
                </el-tooltip>
                <el-tooltip content="编辑" placement="top">
                  <el-button size="small" type="warning" @click="editUser(scope.row)" circle>
                    <el-icon><Edit /></el-icon>
                  </el-button>
                </el-tooltip>
                <el-tooltip content="删除" placement="top">
                  <el-button size="small" type="danger" @click="deleteUser(scope.row)" circle>
                    <el-icon><Delete /></el-icon>
                  </el-button>
                </el-tooltip>
              </div>
            </template>
          </el-table-column>
        </el-table>
      </div>
      
      <!-- 卡片视图 -->
      <div v-else class="card-view">
        <el-row :gutter="20">
          <el-col 
            v-for="user in userList" 
            :key="user.user_id"
            :xs="24" :sm="12" :md="8" :lg="6"
            class="user-card-col"
          >
            <div class="user-card" @click="viewUser(user)">
              <div class="user-card-header">
                <el-avatar :size="60" :src="user.avatar">
                  <el-icon><User /></el-icon>
                </el-avatar>
                <el-tag 
                  :type="user.status === 'active' ? 'success' : 'danger'"
                  class="status-tag"
                >
                  {{ user.status === 'active' ? '活跃' : '禁用' }}
                </el-tag>
              </div>
              <div class="user-card-body">
                <h3 class="user-name">{{ user.username }}</h3>
                <p class="user-email">{{ user.email }}</p>
                <p class="user-phone">{{ user.phone }}</p>
                <p class="user-date">{{ formatDate(user.created_at) }}</p>
              </div>
              <div class="user-card-actions">
                <el-button size="small" type="warning" @click.stop="editUser(user)">
                  <el-icon><Edit /></el-icon>
                </el-button>
                <el-button size="small" type="danger" @click.stop="deleteUser(user)">
                  <el-icon><Delete /></el-icon>
                </el-button>
              </div>
            </div>
          </el-col>
        </el-row>
      </div>

      <!-- 批量操作 -->
      <div v-if="selectedUsers.length > 0" class="batch-actions">
        <el-alert 
          :title="`已选择 ${selectedUsers.length} 个用户`"
          type="info"
          show-icon
          :closable="false"
        >
          <template #default>
            <div class="batch-buttons">
              <el-button size="small" type="info" @click="showBatchMenu">
                <el-icon><MenuIcon /></el-icon>
                批量操作
              </el-button>
              <el-button size="small" type="warning" @click="batchEdit">
                <el-icon><Edit /></el-icon>
                批量编辑
              </el-button>
              <el-button size="small" type="danger" @click="batchDelete">
                <el-icon><Delete /></el-icon>
                批量删除
              </el-button>
            </div>
          </template>
        </el-alert>
      </div>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          background
        />
      </div>
    </el-card>

    <!-- 添加/编辑用户对话框 -->
    <el-dialog
      v-model="showAddDialog"
      :title="isEdit ? '编辑用户' : '添加用户'"
      width="600px"
      :close-on-click-modal="false"
      class="user-dialog"
    >
      <el-form
        ref="userFormRef"
        :model="userForm"
        :rules="userRules"
        label-width="80px"
        class="user-form"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户名" prop="username">
              <el-input v-model="userForm.username" placeholder="请输入用户名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="userForm.email" placeholder="请输入邮箱" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="userForm.phone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="userForm.status" placeholder="选择状态">
                <el-option label="活跃" value="active" />
                <el-option label="禁用" value="disabled" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="头像" prop="avatar">
          <el-upload
            class="avatar-uploader"
            action="#"
            :show-file-list="false"
            :before-upload="beforeAvatarUpload"
          >
            <img v-if="userForm.avatar" :src="userForm.avatar" class="avatar" />
            <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="saveUser" :loading="saving">
            {{ isEdit ? '更新' : '添加' }}
          </el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 用户详情对话框 -->
    <el-dialog
      v-model="showDetailDialog"
      title="用户详情"
      width="500px"
      class="detail-dialog"
    >
      <div v-if="currentUser" class="user-detail">
        <div class="detail-header">
          <el-avatar :size="80" :src="currentUser.avatar">
            <el-icon><User /></el-icon>
          </el-avatar>
          <div class="detail-info">
            <h2>{{ currentUser.username }}</h2>
            <el-tag 
              :type="currentUser.status === 'active' ? 'success' : 'danger'"
              size="large"
            >
              {{ currentUser.status === 'active' ? '活跃' : '禁用' }}
            </el-tag>
          </div>
        </div>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="用户ID">{{ currentUser.user_id }}</el-descriptions-item>
          <el-descriptions-item label="邮箱">{{ currentUser.email }}</el-descriptions-item>
          <el-descriptions-item label="手机号">{{ currentUser.phone }}</el-descriptions-item>
          <el-descriptions-item label="注册时间">{{ formatDate(currentUser.created_at) }}</el-descriptions-item>
          <el-descriptions-item label="最后登录">{{ formatDate(currentUser.last_login) }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  User, Plus, Search as SearchIcon, Refresh, Edit, Delete, View as ViewIcon, Download,
  UserFilled, Star, Clock, List, Grid, Menu as MenuIcon, ArrowUp, ArrowDown
} from '@element-plus/icons-vue'

export default {
  name: 'UserManagement',
  components: {
    User, Plus, SearchIcon, Refresh, Edit, Delete, ViewIcon, Download,
    UserFilled, Star, Clock, List, Grid, MenuIcon, ArrowUp, ArrowDown
  },
  setup() {
    const loading = ref(false)
    const saving = ref(false)
    const showAddDialog = ref(false)
    const showDetailDialog = ref(false)
    const isEdit = ref(false)
    const userFormRef = ref()
    const searchExpanded = ref(true)
    const viewMode = ref('table')
    const selectedUsers = ref([])
    const currentUser = ref(null)
    
    // 用户统计数据
    const userStats = reactive({
      total: 1234,
      active: 1156,
      newToday: 23,
      subscribed: 567
    })
    
    // 搜索表单
    const searchForm = reactive({
      username: '',
      email: '',
      phone: '',
      status: ''
    })
    
    // 用户表单
    const userForm = reactive({
      user_id: '',
      username: '',
      email: '',
      phone: '',
      status: 'active',
      avatar: ''
    })
    
    // 表单验证规则
    const userRules = {
      username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
        { min: 2, max: 20, message: '用户名长度在 2 到 20 个字符', trigger: 'blur' }
      ],
      email: [
        { required: true, message: '请输入邮箱', trigger: 'blur' },
        { type: 'email', message: '请输入正确的邮箱格式', trigger: 'blur' }
      ],
      phone: [
        { required: true, message: '请输入手机号', trigger: 'blur' },
        { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
      ]
    }
    
    // 分页数据
    const currentPage = ref(1)
    const pageSize = ref(20)
    const total = ref(0)
    
    // 用户列表
    const userList = ref([
      {
        user_id: 1,
        username: '张三',
        email: 'zhangsan@example.com',
        phone: '13800138001',
        status: 'active',
        avatar: '',
        is_vip: true,
        created_at: '2024-01-15 10:30:00',
        last_login: '2024-01-20 15:45:00'
      },
      {
        user_id: 2,
        username: '李四',
        email: 'lisi@example.com',
        phone: '13800138002',
        status: 'active',
        avatar: '',
        is_vip: false,
        created_at: '2024-01-16 14:20:00',
        last_login: '2024-01-19 09:15:00'
      },
      {
        user_id: 3,
        username: '王五',
        email: 'wangwu@example.com',
        phone: '13800138003',
        status: 'disabled',
        avatar: '',
        is_vip: false,
        created_at: '2024-01-17 16:45:00',
        last_login: '2024-01-18 11:30:00'
      }
    ])
    
    // 方法
    const toggleSearchExpand = () => {
      searchExpanded.value = !searchExpanded.value
    }
    
    const searchUsers = () => {
      loading.value = true
      // 模拟搜索
      setTimeout(() => {
        loading.value = false
        ElMessage.success('搜索完成')
      }, 1000)
    }
    
    const handleSearch = () => {
      searchUsers()
    }
    
    const resetSearch = () => {
      Object.assign(searchForm, {
        username: '',
        email: '',
        phone: '',
        status: ''
      })
      handleSearch()
    }
    
    const handleSelectionChange = (selection) => {
      selectedUsers.value = selection
    }
    
    const viewUser = (user) => {
      currentUser.value = user
      showDetailDialog.value = true
    }
    
    const editUser = (user) => {
      isEdit.value = true
      Object.assign(userForm, user)
      showAddDialog.value = true
    }
    
    const deleteUser = (user) => {
      ElMessageBox.confirm(
        `确定要删除用户 "${user.username}" 吗？`,
        '确认删除',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      ).then(() => {
        // 模拟删除
        const index = userList.value.findIndex(u => u.user_id === user.user_id)
        if (index > -1) {
          userList.value.splice(index, 1)
          ElMessage.success('删除成功')
        }
      })
    }
    
    const showBatchMenu = () => {
      ElMessage.info('批量操作菜单功能开发中...')
    }
    
    const batchEdit = () => {
      ElMessage.info('批量编辑功能开发中...')
    }
    
    const batchDelete = () => {
      ElMessageBox.confirm(
        `确定要删除选中的 ${selectedUsers.value.length} 个用户吗？`,
        '确认批量删除',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      ).then(() => {
        ElMessage.success('批量删除成功')
        selectedUsers.value = []
      })
    }
    
    const exportUsers = () => {
      ElMessage.success('导出功能开发中...')
    }
    
    const saveUser = () => {
      userFormRef.value.validate((valid) => {
        if (valid) {
          saving.value = true
          setTimeout(() => {
            saving.value = false
            showAddDialog.value = false
            ElMessage.success(isEdit.value ? '更新成功' : '添加成功')
            if (!isEdit.value) {
              userList.value.unshift({
                ...userForm,
                user_id: Date.now(),
                created_at: new Date().toLocaleString(),
                last_login: new Date().toLocaleString()
              })
            }
            resetForm()
          }, 1000)
        }
      })
    }
    
    const resetForm = () => {
      Object.assign(userForm, {
        user_id: '',
        username: '',
        email: '',
        phone: '',
        status: 'active',
        avatar: ''
      })
      isEdit.value = false
    }
    
    const beforeAvatarUpload = (file) => {
      const isJPG = file.type === 'image/jpeg' || file.type === 'image/png'
      const isLt2M = file.size / 1024 / 1024 < 2
      
      if (!isJPG) {
        ElMessage.error('头像只能是 JPG/PNG 格式!')
      }
      if (!isLt2M) {
        ElMessage.error('头像大小不能超过 2MB!')
      }
      return isJPG && isLt2M
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return '-'
      return new Date(dateString).toLocaleString('zh-CN')
    }
    
    const handleSizeChange = (size) => {
      pageSize.value = size
      handleSearch()
    }
    
    const handleCurrentChange = (page) => {
      currentPage.value = page
      handleSearch()
    }
    
    onMounted(() => {
      total.value = userList.value.length
    })
    
    return {
      loading,
      saving,
      showAddDialog,
      showDetailDialog,
      isEdit,
      userFormRef,
      searchExpanded,
      viewMode,
      selectedUsers,
      currentUser,
      userStats,
      searchForm,
      userForm,
      userRules,
      currentPage,
      pageSize,
      total,
      userList,
      toggleSearchExpand,
      searchUsers,
      handleSearch,
      resetSearch,
      handleSelectionChange,
      viewUser,
      editUser,
      deleteUser,
      showBatchMenu,
      batchEdit,
      batchDelete,
      exportUsers,
      saveUser,
      resetForm,
      beforeAvatarUpload,
      formatDate,
      handleSizeChange,
      handleCurrentChange
    }
  }
}
</script>

<style scoped>
.user-management {
  padding: 0;
}

/* 页面头部 */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  color: white;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
}

.header-left .page-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 8px;
}

.title-icon {
  font-size: 28px;
}

.page-description {
  opacity: 0.9;
  font-size: 14px;
}

.header-actions {
  display: flex;
  gap: 12px;
}

.add-btn, .export-btn {
  background: rgba(255, 255, 255, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: white;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
}

.add-btn:hover, .export-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

/* 统计卡片 */
.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  margin-bottom: 15px;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  color: white;
  font-size: 24px;
}

.total-users .stat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.active-users .stat-icon {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.new-users .stat-icon {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.subscription-users .stat-icon {
  background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
}

.stat-content {
  flex: 1;
}

.stat-number {
  font-size: 28px;
  font-weight: bold;
  color: #303133;
  margin-bottom: 5px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

/* 搜索卡片 */
.search-card {
  margin-bottom: 20px;
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.3s ease;
}

.search-card:hover {
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: #303133;
}

.expand-btn {
  margin-left: auto;
  color: #909399;
}

.search-form {
  padding-top: 10px;
}

.search-actions {
  text-align: right;
  margin-top: 10px;
}

/* 表格卡片 */
.table-card {
  border-radius: 12px;
  overflow: hidden;
}

.table-actions {
  margin-left: auto;
}

.user-table {
  border-radius: 8px;
  overflow: hidden;
}

.user-info-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.username {
  font-weight: 500;
}

.time-cell {
  display: flex;
  align-items: center;
  gap: 5px;
  color: #606266;
}

.action-buttons {
  display: flex;
  gap: 8px;
}

/* 卡片视图 */
.card-view {
  margin-top: 20px;
}

.user-card-col {
  margin-bottom: 20px;
}

.user-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  cursor: pointer;
  position: relative;
}

.user-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
}

.user-card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 15px;
}

.status-tag {
  position: absolute;
  top: 15px;
  right: 15px;
}

.user-card-body {
  text-align: center;
  margin-bottom: 15px;
}

.user-name {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 8px;
}

.user-email, .user-phone, .user-date {
  color: #606266;
  font-size: 14px;
  margin-bottom: 4px;
}

.user-card-actions {
  display: flex;
  justify-content: center;
  gap: 10px;
}

/* 批量操作 */
.batch-actions {
  margin: 20px 0;
}

.batch-buttons {
  display: flex;
  gap: 10px;
  margin-top: 10px;
}

/* 分页 */
.pagination {
  display: flex;
  justify-content: center;
  margin-top: 20px;
  padding: 20px 0;
}

/* 对话框 */
.user-dialog .user-form {
  padding: 20px 0;
}

.avatar-uploader {
  border: 2px dashed #d9d9d9;
  border-radius: 8px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: all 0.3s ease;
  width: 120px;
  height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.avatar-uploader:hover {
  border-color: #409eff;
}

.avatar {
  width: 120px;
  height: 120px;
  object-fit: cover;
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
}

.dialog-footer {
  text-align: right;
}

/* 用户详情 */
.detail-dialog .user-detail {
  padding: 20px 0;
}

.detail-header {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 20px;
  padding-bottom: 20px;
  border-bottom: 1px solid #ebeef5;
}

.detail-info h2 {
  margin-bottom: 10px;
  color: #303133;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    gap: 15px;
    text-align: center;
  }
  
  .header-actions {
    width: 100%;
    justify-content: center;
  }
  
  .search-form .el-form-item {
    margin-bottom: 15px;
  }
  
  .action-buttons {
    flex-direction: column;
    gap: 5px;
  }
  
  .batch-buttons {
    flex-direction: column;
  }
}

@media (max-width: 480px) {
  .stat-card {
    flex-direction: column;
    text-align: center;
    gap: 10px;
  }
  
  .stat-icon {
    margin-right: 0;
    margin-bottom: 10px;
  }
  
  .user-card {
    padding: 15px;
  }
  
  .pagination {
    padding: 15px 0;
  }
}

/* 动画效果 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.stat-card, .search-card, .table-card {
  animation: fadeInUp 0.6s ease-out;
}

.stat-card:nth-child(1) { animation-delay: 0.1s; }
.stat-card:nth-child(2) { animation-delay: 0.2s; }
.stat-card:nth-child(3) { animation-delay: 0.3s; }
.stat-card:nth-child(4) { animation-delay: 0.4s; }
</style>