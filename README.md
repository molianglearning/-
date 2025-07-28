# 医疗专家管理系统

## 📋 项目简介

基于Vue.js + Element Plus的医疗专家后台管理系统，提供用户管理、专家管理、标签管理等功能。

## 🛠 技术栈

- **前端框架**: Vue 3
- **UI组件库**: Element Plus
- **状态管理**: Pinia
- **路由管理**: Vue Router
- **构建工具**: Vite
- **代码规范**: ESLint + Prettier
- **测试框架**: Playwright
- **容器化**: Docker

## 🚀 快速开始

### 开发环境

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览生产版本
npm run preview
```

### Docker部署

```bash
# 构建并启动所有服务
docker-compose up -d

# 仅启动前端服务
docker-compose up frontend

# 查看服务状态
docker-compose ps

# 停止所有服务
docker-compose down
```

## 📁 项目结构

```
├── src/
│   ├── assets/          # 静态资源
│   ├── components/      # 公共组件
│   ├── router/          # 路由配置
│   ├── stores/          # 状态管理
│   ├── views/           # 页面组件
│   ├── App.vue          # 根组件
│   └── main.js          # 入口文件
├── public/              # 公共静态资源
├── e2e/                 # E2E测试
├── Dockerfile           # Docker配置
├── docker-compose.yml   # Docker编排
├── nginx.conf           # Nginx配置
└── database.sql         # 数据库初始化脚本
```

## 🔧 功能模块

- **🏠 主界面**: 系统概览和数据统计
- **👥 用户管理**: 用户信息的增删改查
- **👨‍⚕️ 专家管理**: 医疗专家信息管理
- **🏷️ 标签管理**: 标签分类和管理

## 🐳 Docker容器化说明

### 作用和优势

1. **环境一致性**: 确保开发、测试、生产环境完全一致
2. **快速部署**: 一键部署，无需复杂的环境配置
3. **资源隔离**: 容器间相互隔离，避免依赖冲突
4. **可扩展性**: 支持水平扩展和负载均衡
5. **版本管理**: 镜像版本化，便于回滚和升级

### 容器架构

- **Frontend**: Nginx + Vue.js构建的静态文件
- **Backend**: Node.js API服务（预留）
- **Database**: MySQL 8.0数据库

## 📚 GitHub代码管理说明

### 作用和优势

1. **版本控制**: 完整的代码变更历史记录
2. **协作开发**: 多人协作，分支管理
3. **代码备份**: 云端备份，数据安全
4. **CI/CD集成**: 自动化构建和部署
5. **问题追踪**: Issue管理和Bug跟踪

### Git工作流

```bash
# 初始化仓库
git init
git add .
git commit -m "Initial commit: 医疗专家管理系统"

# 连接远程仓库
git remote add origin https://github.com/yourusername/medical-expert-admin.git
git branch -M main
git push -u origin main

# 日常开发流程
git checkout -b feature/new-feature
git add .
git commit -m "feat: 添加新功能"
git push origin feature/new-feature
```

## 🔍 代码质量

```bash
# 代码检查
npm run lint

# 代码格式化
npm run format

# E2E测试
npm run test:e2e
```

## 📝 开发规范

- 使用ESLint进行代码检查
- 使用Prettier进行代码格式化
- 遵循Vue.js官方风格指南
- 提交信息遵循Conventional Commits规范

## 🌐 访问地址

- **开发环境**: http://localhost:5173
- **Docker部署**: http://localhost:80
- **数据库**: localhost:3306

## 📄 许可证

MIT License

## 🤝 贡献指南

1. Fork本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

This template should help get you started developing with Vue 3 in Vite.

## Recommended IDE Setup

[VSCode](https://code.visualstudio.com/) + [Volar](https://marketplace.visualstudio.com/items?itemName=Vue.volar) (and disable Vetur).

## Customize configuration

See [Vite Configuration Reference](https://vite.dev/config/).

## Project Setup

```sh
npm install
```

### Compile and Hot-Reload for Development

```sh
npm run dev
```

### Compile and Minify for Production

```sh
npm run build
```

### Run End-to-End Tests with [Playwright](https://playwright.dev)

```sh
# Install browsers for the first run
npx playwright install

# When testing on CI, must build the project first
npm run build

# Runs the end-to-end tests
npm run test:e2e
# Runs the tests only on Chromium
npm run test:e2e -- --project=chromium
# Runs the tests of a specific file
npm run test:e2e -- tests/example.spec.ts
# Runs the tests in debug mode
npm run test:e2e -- --debug
```

### Lint with [ESLint](https://eslint.org/)

```sh
npm run lint
```
