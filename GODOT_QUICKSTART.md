# 🎮 Godot 操作指南 — 江湖打工人

**写给 Kay 的快速上手手册**

---

## 第 1 步：安装 Godot（5 分钟）

1. 去 https://godotengine.org/download
2. 下载 **Godot 4.3 Stable**（Standard 版本）
3. Windows 下载 `Godot_v4.3-stable_win64.exe`
4. 下载后直接双击运行，**不需要安装**

---

## 第 2 步：打开项目（2 分钟）

1. 打开 Godot 编辑器
2. 点 **Import**（导入）
3. 路径选到：`你的项目路径/godot-project/`
4. 这个文件夹里已经有 `project.godot` 文件
5. 点 **Import & Edit**

---

## 第 3 步：运行测试（1 分钟）

1. 打开项目后，左上角看到场景树
2. 按 **F5** 或点右上角的 **▶️ 播放按钮**
3. 如果问"哪个场景是主场景"，选 `main_menu.tscn`
4. 应该能看到主菜单界面
5. 点"开始战斗"进入战斗场景

---

## 第 4 步：理解项目结构

```
godot-project/
├── project.godot          ← 项目配置（不用动）
├── scenes/
│   ├── main_menu.tscn     ← 主菜单场景
│   └── battle.tscn        ← 战斗场景
├── scripts/
│   ├── main_menu.gd       ← 主菜单逻辑
│   ├── battle_controller.gd  ← ⭐ 战斗核心逻辑
│   ├── battle_scene.gd    ← ⭐ 战斗渲染+输入
│   └── battle_ui.gd       ← 战斗 UI
└── assets/                ← 美术资源（后续放入）
    ├── characters/
    ├── tiles/
    ├── effects/
    └── ui/
```

---

## 第 5 步：当前能做什么

### 可以运行的功能
- ✅ 主菜单 → 开始战斗
- ✅ 六边形战棋战斗（方块代替角色）
- ✅ 点击选择单位
- ✅ 查看单位信息
- ✅ 战斗日志输出
- ✅ 基础回合流程

### 需要你手动做的
- ⏳ 配置六边形 TileMap（需要下载六边形瓦片素材）
- ⏳ 替换角色精灵（需要 AI 生成角色立绘）
- ⏳ 调整 UI 布局（可以在编辑器里拖拽调整）

---

## 第 6 步：学习 Godot 基础

**推荐学习路径（3-5 天）：**

| 天数 | 学习内容 | 资源 |
|------|---------|------|
| Day 1 | Godot 界面、节点、场景 | [官方入门教程](https://docs.godotengine.org/en/stable/getting_started/introduction/index.html) |
| Day 2 | GDScript 基础语法 | [GDScript 参考](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) |
| Day 3 | TileMap 使用 | [TileMap 教程](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html) |
| Day 4 | UI 系统 | [UI 教程](https://docs.godotengine.org/en/stable/tutorials/ui/index.html) |
| Day 5 | 六边形网格专题 | 搜 "Godot hex grid tutorial" |

**推荐视频：**
- YouTube 搜 "Godot 4 tutorial for beginners"
- B 站搜 "Godot 4 入门教程"

---

## 第 7 步：遇到问题怎么办

1. **Godot 报错** → 把错误信息发给我，我帮你改
2. **不知道怎么操作** → 告诉我你想做什么，我告诉你在编辑器里怎么点
3. **代码不工作** → 告诉我预期 vs 实际，我调试
4. **想加新功能** → 告诉我需求，我写代码

---

## ⚠️ 重要提示

### 场景文件（.tscn）注意事项

- 我写的 `.tscn` 文件是文本格式，Godot 4.3 可以直接读取
- **但第一次打开时，Godot 可能会重新保存它们**，这是正常的
- 如果打开场景报错，告诉我具体错误信息

### 脚本文件（.gd）注意事项

- `.gd` 文件是纯文本，我已经放在正确的目录里了
- 在 Godot 里创建节点后，需要把脚本关联到节点上
- 方法：选中节点 → 右侧"脚本"面板 → 点"+" → 选择已有脚本

### 美术资源注意事项

- 现在用的是彩色方块代替角色
- 后续需要放入真实的 PNG 图片到 `assets/` 目录
- 我可以帮你生成 AI 美术资源

---

**现在就去安装 Godot 吧！装好后告诉我，我一步步带你跑起来。**
