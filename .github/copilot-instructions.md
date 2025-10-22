# Netflix Clone iOS 应用程序开发指南

此文档提供了在此 Netflix Clone iOS 项目中进行开发时需要了解的关键信息。

## 项目架构

### 整体结构
- **MVVM 架构模式**：使用 ViewModel 层处理数据转换和业务逻辑
- **模块化组织**：
  - `Controllers/`: UI 控制器（Core 和 General 两个子文件夹）
  - `Models/`: 数据模型定义
  - `Views/`: 可重用 UI 组件
  - `ViewModels/`: 视图模型
  - `Managers/`: 业务管理器（API 调用、数据持久化等）

### 关键组件

1. **网络层 (APICaller)**
- 位置: `Managers/APICaller.swift`
- 负责所有 TMDB API 和 YouTube API 的网络请求
- 使用单例模式: `APICaller.shared`
- API 密钥存储在 `Constants` 结构体中

2. **数据持久化 (DataPersistenceManager)**
- 位置: `Managers/DataPersistenceManager.swift`
- 使用 CoreData 进行本地存储
- 主要用于下载功能的实现
- 数据模型: `NetflixCloneModel.xcdatamodeld`

3. **UI 结构**
- `MainTabBarViewController`: 主要导航控制器，管理四个核心标签页
- 核心页面:
  - `HomeViewController`: 主页面展示
  - `UpComingViewController`: 即将上映内容
  - `SearchViewController`: 搜索功能
  - `DownloadsViewController`: 下载管理

## 开发工作流程

### 环境设置
1. 安装 CocoaPods 依赖:
```bash
pod install
```

2. 必须使用 `.xcworkspace` 文件打开项目，而不是 `.xcodeproj`

### 关键模式和约定

1. **视图复用**
- 使用静态标识符进行 cell 注册：
```swift
static let identifier = "CellIdentifier"
```
- 所有自定义 cell 都需要实现 `configure(with:)` 方法

2. **异步操作处理**
- 网络请求使用逃逸闭包和 Result 类型
- UI 更新必须在主线程进行：
```swift
DispatchQueue.main.async { [weak self] in
    // UI updates
}
```

3. **数据流**
- 视图控制器通过 APICaller 获取数据
- 数据通过 ViewModel 转换后传递给视图
- 下载功能通过 DataPersistenceManager 管理

### 集成点

1. **TMDB API**
- 基础 URL: `https://api.themoviedb.org`
- 图片 URL 格式: `https://image.tmdb.org/t/p/w500/[path]`
- 所有请求需要添加 `api_key` 和 `language=zh-CN` 参数

2. **YouTube API**
- 用于视频预览功能
- 使用 `videoId` 构建嵌入 URL

### 主要设计模式

1. **委托模式**
- 用于视图间通信
- 例如 `CollectionViewTableViewCellDelegate` 处理电影条目的点击事件

2. **单例模式**
- `APICaller.shared`
- `DataPersistenceManager.shared`

3. **观察者模式**
- 使用 `NotificationCenter` 处理下载更新

## 提示和最佳实践

1. **内存管理**
- 在闭包中使用 `[weak self]` 防止循环引用
- 视图控制器和自定义视图需要正确实现 `required init?(coder: NSCoder)`

2. **错误处理**
- 使用 `APIError` 枚举处理网络错误
- 数据持久化错误使用 `DataPersistenceError` 枚举

3. **UI 更新**
- 所有 UI 更新操作都应在主线程执行
- 使用适当的约束来处理不同设备尺寸

4. **资源管理**
- 图片资源存放在 `Assets.xcassets`
- 使用 `SDWebImage` 处理网络图片加载和缓存