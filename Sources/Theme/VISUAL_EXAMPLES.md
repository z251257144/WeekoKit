# WeekoKit 主题视觉示例

## Tip 组件增强对比

### 之前（无边框阴影）
```
┌─────────────────────────────────────┐
│ ℹ️  提示文字                        │
│    这是一条提示信息                  │
└─────────────────────────────────────┘
```
- 平面背景
- 无视觉层次
- 缺乏深度感

### 之后（带边框和阴影）
```
╔═════════════════════════════════════╗
║ ℹ️  提示文字                        ║
║    这是一条提示信息                  ║
╚═════════════════════════════════════╝
   └─ 微妙阴影 ─┘
```
- 细微边框（0.5pt，20% 不透明度）
- 柔和阴影（y: 1pt, blur: 3pt, 10% 黑色）
- 明确的视觉层次
- 更好的内容聚焦

## 设置行组件增强

### WeekoSettingToggleRow

**视觉特性：**
- 彩色图标圆形背景（32×32pt）
- 标题 + 副标题双行布局
- 开关控件对齐
- 8pt 内部间距
- 自适应暗色/浅色模式

**使用场景：**
```swift
WeekoSettingToggleRow(
  icon: "moon.fill",
  tint: .purple,
  title: "夜间模式",
  subtitle: "在低光环境下自动调整界面亮度",
  isOn: $nightMode
)
```

**渲染效果：**
```
┌────────────────────────────────────────────┐
│  🟣  夜间模式                    ⚪ ON  │
│      在低光环境下自动调整界面亮度          │
└────────────────────────────────────────────┘
```

### WeekoSettingActionRow

**视觉特性：**
- 与 ToggleRow 相同的图标和标题布局
- 自定义操作区域（Picker、Stepper、Button 等）
- 操作控件右对齐
- 灵活的内容适配

**使用场景：**
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
  .labelsHidden()
  .pickerStyle(.segmented)
}
```

**渲染效果：**
```
┌────────────────────────────────────────────┐
│  🔵  字体大小              [ 小 | 中 | 大 ] │
│      调整界面文字大小                      │
└────────────────────────────────────────────┘
```

## 主题系统层级

### 表面层级（深色主题）

```
Level 1: #05070C  (最深，背景层)
         ↓
Level 2: #0A0D12  (卡片底层)
         ↓
Level 3: #0F131C  (卡片主层)
         ↓
Level 4: #161D2B  (浮动元素)
         ↓
Level 5: #1E2636  (最亮，弹出层)
```

### 内容层级

```
Primary:   rgba(255, 255, 255, 0.95)  标题、重要文字
           ↓
Secondary: rgba(255, 255, 255, 0.65)  副标题、说明
           ↓
Tertiary:  rgba(255, 255, 255, 0.40)  占位符、禁用
```

## 视觉增强级别对比

### .none（无增强）
```
┌─────────────────┐
│   纯色背景      │
└─────────────────┘
```
- 适用于简洁设计
- 可访问性优先场景

### .borders（仅边框）
```
╔═════════════════╗
║   带边框背景    ║
╚═════════════════╝
```
- 清晰的边界定义
- 适合表单和输入框

### .shadows（仅阴影）
```
┌─────────────────┐
│   带阴影背景    │
└─────────────────┘
   └──阴影──┘
```
- 空间深度感
- 适合卡片和浮层

### .bordersAndShadows（边框+阴影）
```
╔═════════════════╗
║ 边框+阴影背景   ║
╚═════════════════╝
   └──阴影──┘
```
- 最强视觉层次
- 适合重要内容区域

## 可访问性自适应

### 减少透明度开启
- 所有半透明背景 → 不透明纯色
- 模糊效果 → 纯色填充
- 确保文本对比度 ≥ 4.5:1

### 增强对比度开启
- 边框不透明度：20% → 40%
- 阴影不透明度：10% → 20%
- 内容文字对比度提升

### 自动检测和切换
```swift
WeekoAccessibilityObserver()
```
监听系统设置变化，自动调整：
- `reduceTransparency` → 关闭模糊和半透明
- `increaseContrast` → 强化边框和阴影
- `reduceMotion` → 关闭动画过渡

## 设计令牌使用示例

### 间距
```swift
.padding(theme.spacingCompact)     // 8pt
.padding(theme.spacingDefault)     // 16pt
.padding(theme.spacingRelaxed)     // 24pt
```

### 圆角
```swift
.clipShape(RoundedRectangle(cornerRadius: theme.radiusButton))   // 999px (pill)
.clipShape(RoundedRectangle(cornerRadius: theme.radiusCard))     // 16px
.clipShape(Circle())                                               // 50% (avatar)
```

### 表面
```swift
.weekoSurface(level: 1)  // 背景层
.weekoSurface(level: 2)  // 卡片层
.weekoSurface(level: 3)  // 浮动层
```

## 实际应用场景

### 1. 设置页面
```swift
WeekoSettingPage(title: "设置") {
  WeekoSettingSection(title: "通用") {
    // 开关设置
    WeekoSettingToggleRow(...)
    
    WeekoSettingDivider()
    
    // 选择器设置
    WeekoSettingActionRow(...)
  }
  .weekoBorder()    // 自动添加边框
  .weekoShadow()    // 自动添加阴影
}
```

### 2. Tip 提示框
```swift
WeekoTip(
  icon: "info.circle.fill",
  tint: .blue,
  title: "提示",
  message: "这是一条重要提示"
)
.weekoBorder()      // 添加边框
.weekoShadow()      // 添加阴影
```

### 3. 卡片列表
```swift
VStack(spacing: theme.spacingDefault) {
  ForEach(items) { item in
    CardView(item: item)
      .weekoSurface(level: 2)
      .weekoBorder()
      .weekoShadow()
  }
}
.weekoSurface(level: 1)  // 背景
```

## 主题切换动画

虽然当前版本不包含动画，但可以轻松添加：

```swift
.animation(.easeInOut(duration: 0.2), value: theme)
```

建议的过渡效果：
- 颜色变化：0.2s ease-in-out
- 阴影变化：0.15s ease-out
- 边框变化：0.1s linear
