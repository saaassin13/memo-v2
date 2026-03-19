# Memo Flutter App - 项目规格说明

## 项目概述

将 Next.js Web 项目 (memo_v12) 转换为 Flutter 手机应用。

## 功能模块

| 模块 | 说明 | 状态 |
|------|------|------|
| 00-foundation | 项目初始化、目录结构 | 待开发 |
| 01-ui-components | UI 组件库 | 待开发 |
| 02-data-layer | SQLite 数据库、状态管理 | 待开发 |
| 03-navigation | 底部导航、路由配置 | 待开发 |
| 10-home | 首页 (功能入口网格) | 待开发 |
| 11-todo | Todo 待办管理 | 待开发 |
| 12-calendar | 日历视图 | 已完成 |
| 13-profile | 我的 + 设置 | 待开发 |
| 20-memo | 备忘录 (列表/新建/详情) | 待开发 |
| 21-diary | 日记 (日历/新建/详情) | 待开发 |
| 22-countdown | 倒数纪念日 | 待开发 |
| 23-accounting | 记账 | ✅ 已完成 |
| 24-goals | 目标 (列表/详情) | 待开发 |
| 25-weight | 体重记录 | 待开发 |
| 30-optimization | 推送通知、测试、发布 | 待开发 |

## 技术栈

| 类别 | 技术选型 |
|------|---------|
| 框架 | Flutter 3.x |
| 语言 | Dart |
| 状态管理 | Riverpod |
| 路由 | go_router |
| 数据库 | sqflite + drift |
| 图标 | lucide_icons |
| 图表 | fl_chart |
| 日期 | intl |
| 主题 | Material 3 |

## 原 Web 项目参考

- 项目位置: `demo/memo_v12/`
- 4 个主导航 Tab: 应用/Todo/日历/我的
- 6 个功能模块: 备忘录/日记/倒数日/记账/目标/体重
- 17 个页面

## 目录结构

```
spec/
├── README.md                     # 本文件
├── architecture/                 # 架构文档
├── 00-foundation/               # 基础框架
├── 01-ui-components/            # UI 组件库
├── 02-data-layer/               # 数据层
├── 03-navigation/               # 导航系统
├── 10-home/                     # 首页
├── 11-todo/                     # Todo
├── 12-calendar/                 # 日历
├── 13-profile/                  # 我的
├── 20-memo/                     # 备忘录
├── 21-diary/                    # 日记
├── 22-countdown/                # 倒数日
├── 23-accounting/               # 记账
├── 24-goals/                    # 目标
├── 25-weight/                   # 体重
└── 30-optimization/             # 优化发布
```
