<template>
  <div class="tag-management">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1>标签管理</h1>
      <el-button type="primary" @click="showAddDialog = true">
        <el-icon><Plus /></el-icon>
        添加标签
      </el-button>
    </div>

    <!-- 搜索筛选 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="标签名称">
          <el-input v-model="searchForm.tag_name" placeholder="请输入标签名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
          <el-button @click="resetSearch">
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 标签列表 -->
    <el-card class="table-card">
      <el-table :data="tagList" v-loading="loading" stripe>
        <el-table-column prop="tag_id" label="标签ID" width="100" />
        <el-table-column prop="tag_name" label="标签名称" width="200">
          <template #default="scope">
            <el-tag :type="getTagType(scope.row.tag_name)" size="large">
              {{ scope.row.tag_name }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="expert_count" label="关联专家数" width="120">
          <template #default="scope">
            <el-badge :value="scope.row.expert_count" class="expert-badge">
              <span>{{ scope.row.expert_count }} 位专家</span>
            </el-badge>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button size="small" @click="editTag(scope.row)">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-button
              size="small"
              type="danger"
              @click="deleteTag(scope.row)"
              :disabled="scope.row.expert_count > 0"
            >
              <el-icon><Delete /></el-icon>
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

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
        />
      </div>
    </el-card>

    <!-- 添加/编辑标签对话框 -->
    <el-dialog v-model="showAddDialog" :title="isEdit ? '编辑标签' : '添加标签'" width="400px">
      <el-form :model="tagForm" :rules="tagRules" ref="tagFormRef" label-width="80px">
        <el-form-item label="标签名称" prop="tag_name">
          <el-input v-model="tagForm.tag_name" placeholder="请输入标签名称" />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="saveTag">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

export default {
  name: 'TagManagement',
  setup() {
    const loading = ref(false)
    const showAddDialog = ref(false)
    const isEdit = ref(false)
    const tagFormRef = ref()

    // 搜索表单
    const searchForm = reactive({
      tag_name: '',
    })

    // 标签表单
    const tagForm = reactive({
      tag_id: null,
      tag_name: '',
    })

    // 表单验证规则
    const tagRules = {
      tag_name: [
        { required: true, message: '请输入标签名称', trigger: 'blur' },
        { min: 2, max: 50, message: '标签名称长度在 2 到 50 个字符', trigger: 'blur' },
      ],
    }

    // 标签列表数据
    const tagList = ref([
      {
        tag_id: 1,
        tag_name: '心血管',
        expert_count: 5,
        created_at: '2024-01-15 10:30:00',
      },
      {
        tag_id: 2,
        tag_name: '神经内科',
        expert_count: 3,
        created_at: '2024-01-16 14:20:00',
      },
      {
        tag_id: 3,
        tag_name: '消化内科',
        expert_count: 2,
        created_at: '2024-01-17 09:15:00',
      },
      {
        tag_id: 4,
        tag_name: '呼吸内科',
        expert_count: 0,
        created_at: '2024-01-18 16:45:00',
      },
    ])

    // 分页数据
    const currentPage = ref(1)
    const pageSize = ref(10)
    const total = ref(0)

    // 获取标签类型（用于显示不同颜色）
    const getTagType = (tagName) => {
      const types = ['', 'success', 'info', 'warning', 'danger']
      const hash = tagName.split('').reduce((a, b) => {
        a = (a << 5) - a + b.charCodeAt(0)
        return a & a
      }, 0)
      return types[Math.abs(hash) % types.length]
    }

    // 格式化日期
    const formatDate = (dateStr) => {
      if (!dateStr) return ''
      return new Date(dateStr).toLocaleString('zh-CN')
    }

    // 搜索
    const handleSearch = () => {
      console.log('搜索标签:', searchForm)
      // 这里添加搜索逻辑
    }

    // 重置搜索
    const resetSearch = () => {
      searchForm.tag_name = ''
      handleSearch()
    }

    // 编辑标签
    const editTag = (tag) => {
      isEdit.value = true
      Object.assign(tagForm, tag)
      showAddDialog.value = true
    }

    // 删除标签
    const deleteTag = (tag) => {
      if (tag.expert_count > 0) {
        ElMessage.warning('该标签已关联专家，无法删除')
        return
      }

      ElMessageBox.confirm(`确定要删除标签 "${tag.tag_name}" 吗？`, '确认删除', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }).then(() => {
        // 这里添加删除逻辑
        ElMessage.success('删除成功')
      })
    }

    // 保存标签
    const saveTag = () => {
      tagFormRef.value.validate((valid) => {
        if (valid) {
          // 这里添加保存逻辑
          ElMessage.success(isEdit.value ? '更新成功' : '添加成功')
          showAddDialog.value = false
          resetForm()
        }
      })
    }

    // 重置表单
    const resetForm = () => {
      tagForm.tag_id = null
      tagForm.tag_name = ''
      isEdit.value = false
    }

    // 分页处理
    const handleSizeChange = (val) => {
      pageSize.value = val
      // 重新加载数据
    }

    const handleCurrentChange = (val) => {
      currentPage.value = val
      // 重新加载数据
    }

    // 页面初始化
    onMounted(() => {
      total.value = tagList.value.length
    })

    return {
      loading,
      showAddDialog,
      isEdit,
      tagFormRef,
      searchForm,
      tagForm,
      tagRules,
      tagList,
      currentPage,
      pageSize,
      total,
      getTagType,
      formatDate,
      handleSearch,
      resetSearch,
      editTag,
      deleteTag,
      saveTag,
      resetForm,
      handleSizeChange,
      handleCurrentChange,
    }
  },
}
</script>

<style scoped>
.tag-management {
  padding: 0;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h1 {
  margin: 0;
  color: #303133;
  font-size: 24px;
  font-weight: 600;
}

.search-card {
  margin-bottom: 20px;
}

.search-form {
  margin: 0;
}

.table-card {
  margin-bottom: 20px;
}

.pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.expert-badge {
  display: inline-block;
}
</style>
