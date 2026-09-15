# ChatApp - Flutter 聊天应用（演示版）

基于 Flutter 的聊天应用演示，支持注册登录、聊天、朋友圈、联系方式管理。

**当前为本地演示版**，使用模拟数据，无需后端服务即可运行和测试 UI。

## 功能

- **注册/登录** - 邮箱注册，任意邮箱+3位以上密码即可登录
- **聊天** - 与模拟用户（Alice、Bob、Charlie）聊天，消息气泡界面
- **朋友圈** - 发布图文动态，点赞评论，预置演示数据
- **联系方式** - 添加微信/QQ/电话/邮箱，支持上传截图

## 编译 APK

### 方式一：GitHub Actions 自动编译（推荐）

1. 在 GitHub 创建新仓库
2. 推送代码：
   ```bash
   cd chat_app
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/你的用户名/chat-app.git
   git push -u origin main
   ```
3. 等待 Actions 自动编译（约 5-10 分钟）
4. 在 Actions 页面下载 APK

### 方式二：本地编译

需要安装 Flutter SDK 和 Android Studio：
```bash
flutter pub get
flutter build apk
```

## 项目结构

```
lib/
├── main.dart                 # 入口
├── services/
│   └── app_data.dart         # 数据层（模拟数据 + 状态管理）
└── screens/
    ├── auth/                 # 登录注册
    ├── home/                 # 主页导航
    ├── chat/                 # 聊天
    ├── moments/              # 朋友圈
    └── contacts/             # 联系方式
```
