# WeekoKit 主题增强实现

## 概述

已为 WeekoKit 添加完整的主题系统和视觉增强功能，包括：
- 统一的设计令牌系统
- 浅色/深色自适应主题
- 边框和阴影视觉增强
- 可访问性支持
- 完整的设置组件

## 新增组件

### 1. 主题系统 (`Sources/Theme/`)

#### WeekoTheme.swift
定义主题协议，包含：
- 表面层级（5-7 层，从 #05070C 到 #1E2636）
- 内容颜色（主要、次要、三级）
- 强调色和状态色
- 语义化间距和圆角

#### WeekoDefaultDarkTheme.swift / WeekoDefaultLightTheme.swift
- 深色主题：近黑表面层级 + 青色强调
- 浅色主题：柔和灰色层级 + 蓝色强调

#### WeekoAdaptiveTheme.swift
根据系统外观自动切换浅色/深色主题

#### WeekoFoundationTokens.swift
全局设计令牌：
- 表面层级：`surface1` 到 `surface7`
- 圆角：`radiusButton`（999px pill）、`radiusCard`（16px）
- 间距：`spacingCompact`（8px）、`spacingInline`（12px）等

#### WeekoVisualEnhancement.swift
视觉增强选项：
- `.none`：无增强
- `.borders`：添加细边框
- `.shadows`：添加微妙阴影
- `.bordersAndShadows`：边框 + 阴影

#### WeekoAccessibilityObserver.swift
监听系统可访问性设置（减少透明度、增强对比度）并自动调整视觉增强

#### WeekoThemeEnvironment.swift
提供 SwiftUI 环境键：
- `\.weekoTheme`：当前主题
- `\.weekoVisualEnhancement`：视觉增强级别

#### WeekoViewExtensions.swift
便捷的视图修饰符：
```swift
.weekoSurface(level: 1)         // 应用表面层级
.weekoBorder()                   // 应用主题边框
.weekoShadow()                   // 应用主题阴影
```

### 2. 增强的设置组件 (`Sources/Settings/`)

#### WeekoSettingToggleRow
带图标、标题、副标题的开关行：
```swift
WeekoSettingToggleRow(
  icon: "moon.fill",
  tint: .purple,
  title: "夜间模式",
  subtitle: "在低光环境下自动调整界面亮度",
  isOn: $nightMode
)
```

#### WeekoSettingActionRow
带自定义操作控件的设置行：
```swift
WeekoSettingActionRow(
  icon: "textformat.size",
  tint: .blue,
  title: "字体大小",
  subtitle: "调整界面文字大小"
) {
  Picker("", selection: $fontSize) {
    Text("小").tag(12)
    Text("中").tag(14)
    Text("大").tag(16)
  }
}
```

#### WeekoSettingSection 增强
- 自动应用主题表面层级
- 支持边框和阴影
- 响应可访问性设置

### 3. Demo 页面

#### DemoThemePage.swift
完整的主题演示页面，展示：
- 主题选择（浅色/深色/自动）
- 视觉增强选择
- 所有设置组件的实时预览
- 可访问性状态显示

## 使用方法

### 1. 应用主题

在应用根视图应用主题：

```swift
ContentView()
  .weekoTheme(.adaptive)  // 自动适应系统外观
  .weekoAccessibilityObserver()  // 自动适应可访问性设置
```

或手动选择主题：

```swift
ContentView()
  .weekoTheme(.defaultDark)  // 强制深色
  .weekoVisualEnhancement(.bordersAndShadows)  // 启用边框和阴影
```

### 2. 在视图中使用主题

```swift
struct MyView: View {
  @Environment(\.weekoTheme) var theme
  @Environment(\.weekoVisualEnhancement) var enhancement
  
  var body: some View {
    VStack {
      Text("标题")
        .foregroundStyle(theme.contentPrimary)
      
      Text("副标题")
        .foregroundStyle(theme.contentSecondary)
    }
    .weekoSurface(level: 2)  // 应用表面层级 2
    .weekoBorder()            // 根据 enhancement 自动添加边框
    .weekoShadow()            // 根据 enhancement 自动添加阴影
  }
}
```

### 3. 构建设置页面

```swift
WeekoSettingPage(title: "设置") {
  WeekoSettingSection(title: "通用") {
    WeekoSettingToggleRow(
      icon: "bell.fill",
      tint: .orange,
      title: "通知",
      subtitle: "接收重要提醒和更新",
      isOn: $notifications
    )
    
    WeekoSettingActionRow(
      icon: "globe",
      tint: .blue,
      title: "语言",
      subtitle: "选择应用显示语言"
    ) {
      Picker("", selection: $language) {
        Text("简体中文").tag("zh-Hans")
        Text("English").tag("en")
      }
    }
  }
}
```

## 设计原则

### 表面层级
采用 5-7 层表面层级，从近黑（#05070C，3-6% 亮度）逐步提升，每层都略微偏向主题色调：
- 数据类应用：青色和翡翠色调
- 工具类应用：黄铜和琥珀色调
- 社交类应用：暖陶土色调

### 强调色
- 高饱和度单一强调色（如 #38BDF8 cyan、#6EE7B7 emerald）
- 一个柔和的辅助色调
- 避免平面白色背景和紫色渐变

### 排版
- 使用 `clamp()` 流式缩放（从显示字体到正文）
- 所有字体族声明为自定义属性并通过 `var()` 引用
- 显示字号紧密负间距，正文大行高

### 布局
- CSS Grid 主导：页面框架、节奏、卡片字段
- Flex 仅用于组件内部
- 完全圆角：按钮 999px pill，头像 50% 圆形
- 所有半径值使用令牌

### 组件
- 在样式前标记化：间距、圆角、表面、阴影都声明为自定义属性
- 通过 `var()` 独占消费
- 令牌系统可见化——跨节的一致节奏显得深思熟虑

## 验证

所有更改已通过验证：
- ✓ plutil validation（25 种语言）
- ✓ 无重复键
- ✓ Swift 测试通过
- ✓ WeekoKitDemo 构建成功

## 文件清单

### 新增文件
- `Sources/Theme/WeekoTheme.swift`
- `Sources/Theme/WeekoDefaultDarkTheme.swift`
- `Sources/Theme/WeekoDefaultLightTheme.swift`
- `Sources/Theme/WeekoAdaptiveTheme.swift`
- `Sources/Theme/WeekoFoundationTokens.swift`
- `Sources/Theme/WeekoVisualEnhancement.swift`
- `Sources/Theme/WeekoAccessibilityObserver.swift`
- `Sources/Theme/WeekoThemeEnvironment.swift`
- `Sources/Theme/WeekoViewExtensions.swift`
- `Sources/Theme/README.md`
- `WeekoKitDemo/WeekoKitDemo/DemoThemePage.swift`

### 修改文件
- `Sources/Settings/WeekoSettingRows.swift`（+193/-67 行）
- `Sources/Settings/WeekoSettingSection.swift`（+16 行）

## 下一步

可以考虑：
1. 添加更多预设主题（如暖色调、冷色调等）
2. 支持自定义主题配色
3. 添加主题动画过渡
4. 持久化用户主题选择
5. 支持动态类型（Dynamic Type）字体缩放
