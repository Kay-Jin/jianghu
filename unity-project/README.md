# Jianghu Unity Project

3D 开放世界武侠沙盒 —— 本目录为 **Unity 6 LTS** 项目根目录。

**请从仓库根目录的 [`UNITY_QUICKSTART.md`](../UNITY_QUICKSTART.md) 开始阅读。**

## 目录

```text
unity-project/
├── Assets/
│   ├── Scripts/            C# 源码（核心原型）
│   ├── Scenes/             .unity 场景
│   ├── Art/                模型 / 贴图 / 动画
│   ├── Prefabs/            Prefab
│   └── Settings/           URP / Input / 其他配置
├── Packages/
│   └── manifest.json       依赖清单
├── ProjectSettings/
│   └── ProjectVersion.txt  Unity 版本（6000.0.x）
└── .gitignore              Unity 忽略规则（Library/Temp 等）
```

## 依赖

`Packages/manifest.json` 锁定了以下关键依赖（首次打开 Unity 时自动安装）：

- Universal Render Pipeline (URP) 17.x
- Cinemachine 3.x
- Input System 1.11.x
- TextMeshPro / Timeline / Visual Scripting

## 首次打开

1. Unity Hub → Add project from disk → 选择本目录（`unity-project/`）。
2. 等待 `Library/` 生成（3-10 分钟）。
3. 新建场景 `Assets/Scenes/MainScene.unity`，添加空 GameObject 并挂 `SceneBootstrap.cs`，按 Play。
