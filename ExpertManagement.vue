<template>
  <div class="expert-management">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1>专家管理</h1>
      <el-button type="primary" @click="showAddDialog = true">
        <el-icon><Plus /></el-icon>
        添加专家
      </el-button>
    </div>

    <!-- 搜索筛选 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="专家姓名">
          <el-input v-model="searchForm.name" placeholder="请输入专家姓名" clearable />
        </el-form-item>
        <el-form-item label="专业领域">
          <el-input v-model="searchForm.specialty" placeholder="请输入专业领域" clearable />
        </el-form-item>
        <el-form-item label="医院">
          <el-input v-model="searchForm.hospital" placeholder="请输入医院名称" clearable />
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

    <!-- 专家列表 -->
    <el-card class="table-card">
      <el-table :data="expertList" v-loading="loading" stripe>
        <el-table-column prop="expert_id" label="专家ID" width="80" />
        <el-table-column prop="name" label="姓名" width="100" />
        <el-table-column prop="title" label="职称" width="120" />
        <el-table-column prop="specialty" label="专业领域" width="150" />
        <el-table-column prop="hospital" label="医院" width="180" />
        <el-table-column prop="subscription_fee" label="订阅费用" width="100">
          <template #default="scope"> ¥{{ scope.row.subscription_fee }} </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250">
          <template #default="scope">
            <el-button size="small" @click="viewExpert(scope.row)">
              <el-icon><View /></el-icon>
              查看
            </el-button>
            <el-button size="small" @click="editExpert(scope.row)">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-button size="small" type="danger" @click="deleteExpert(scope.row)">
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

    <!-- 添加/编辑专家对话框 -->
    <el-dialog v-model="showAddDialog" :title="isEdit ? '编辑专家' : '添加专家'" width="600px">
      <el-form :model="expertForm" :rules="expertRules" ref="expertFormRef" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="专家姓名" prop="name">
              <el-input v-model="expertForm.name" placeholder="请输入专家姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="职称" prop="title">
              <el-input v-model="expertForm.title" placeholder="请输入职称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="专业领域" prop="specialty">
              <el-input v-model="expertForm.specialty" placeholder="请输入专业领域" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="医院" prop="hospital">
              <el-input v-model="expertForm.hospital" placeholder="请输入医院名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="订阅费用" prop="subscription_fee">
          <el-input-number
            v-model="expertForm.subscription_fee"
            :min="0"
            :precision="2"
            placeholder="请输入订阅费用"
          />
        </el-form-item>
        <el-form-item label="专家简介" prop="description">
          <el-input
            v-model="expertForm.description"
            type="textarea"
            :rows="4"
            placeholder="请输入专家简介"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showAddDialog = false">取消</el-button>
          <el-button type="primary" @click="saveExpert">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

export default {
  name: 'ExpertManagement',
  setup() {
    const loading = ref(false)
    const showAddDialog = ref(false)
    const isEdit = ref(false)
    const expertFormRef = ref()

    // 搜索表单
    const searchForm = reactive({
      name: '',
      specialty: '',
      hospital: '',
    })

    // 专家表单
    const expertForm = reactive({
      expert_id: null,
      name: '',
      title: '',
      specialty: '',
      hospital: '',
      description: '',
      subscription_fee: 0,
    })

    // 表单验证规则
    const expertRules = {
      name: [
        { required: true, message: '请输入专家姓名', trigger: 'blur' },
        { min: 2, max: 50, message: '姓名长度在 2 到 50 个字符', trigger: 'blur' },
      ],
      specialty: [{ required: true, message: '请输入专业领域', trigger: 'blur' }],
      subscription_fee: [{ required: true, message: '请输入订阅费用', trigger: 'blur' }],
    }

    // 专家列表数据
    const expertList = ref([
      {
        expert_id: 1,
        name: '张医生',
        title: '主任医师',
        specialty: '心血管内科',
        hospital: '北京协和医院',
        description: '从事心血管疾病诊治20余年，擅长冠心病、高血压等疾病的治疗。',
        subscription_fee: 299.0,
        created_at: '2024-01-15 10:30:00',
      },
      {
        expert_id: 2,
        name: '李医生',
        title: '副主任医师',
        specialty: '神经内科',
        hospital: '上海华山医院',
        description: '专注于神经系统疾病的诊断和治疗，在脑血管病方面有丰富经验。',
        subscription_fee: 199.0,
        created_at: '2024-01-16 14:20:00',
      },
    ])

    // 分页数据
    const currentPage = ref(1)
    const pageSize = ref(10)
    const total = ref(0)

    // 格式化日期
    const formatDate = (dateStr) => {
      if (!dateStr) return ''
      return new Date(dateStr).toLocaleString('zh-CN')
    }

    // 搜索
    const handleSearch = () => {
      console.log('搜索专家:', searchForm)
      // 这里添加搜索逻辑
    }

    // 重置搜索
    const resetSearch = () => {
      Object.keys(searchForm).forEach((key) => {
        searchForm[key] = ''
      })
      handleSearch()
    }

    // 查看专家
    const viewExpert = () => {
      ElMessage.info('查看专家详情功能待开发')
    }

    // 编辑专家
    const editExpert = (expert) => {
      isEdit.value = true
      Object.assign(expertForm, expert)
      showAddDialog.value = true
    }

    // 删除专家
    const deleteExpert = (expert) => {
      ElMessageBox.confirm(`确定要删除专家 "${expert.name}" 吗？`, '确认删除', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }).then(() => {
        // 这里添加删除逻辑
        ElMessage.success('删除成功')
      })
    }

    // 保存专家
    const saveExpert = () => {
      expertFormRef.value.validate((valid) => {
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
      Object.keys(expertForm).forEach((key) => {
        if (key === 'expert_id') {
          expertForm[key] = null
        } else if (key === 'subscription_fee') {
          expertForm[key] = 0
        } else {
          expertForm[key] = ''
        }
      })
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
      total.value = expertList.value.length
    })

    return {
      loading,
      showAddDialog,
      isEdit,
      expertFormRef,
      searchForm,
      expertForm,
      expertRules,
      expertList,
      currentPage,
      pageSize,
      total,
      formatDate,
      handleSearch,
      resetSearch,
      viewExpert,
      editExpert,
      deleteExpert,
      saveExpert,
      resetForm,
      handleSizeChange,
      handleCurrentChange,
    }
  },
}
</script>

<style scoped>
.expert-management {
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
</style>
