# iOS「零联网」自证清单 / Zero-Network Proof Checklist

> 用途：把「我的 App 全本地运行」从一句口头声明，变成**可举证的证据包**。
> 苹果 ICP 豁免申诉拼的不是措辞，是你有没有拿出**空白的抓包记录 + 干净的依赖清单**。
> 任何一项没做扎实，申诉被驳回，就得回去走备案（2-4 周）。

---

## 0. 先想清一件事：你要证明的是「App 不发请求」，不是「手机不联网」

抓包里一定会看到一些流量，**它们不是你的 App 发的**，别自己先慌：

| 抓到的域名                                   | 谁发的                | 要不要解释                   |
| -------------------------------------------- | --------------------- | ---------------------------- |
| `ocsp.apple.com`、`crl.apple.com`            | iOS 系统查证书吊销    | 不是 App 行为，标注即可      |
| `gsp-ssl.ls.apple.com`、`gateway.icloud.com` | 系统服务、iCloud 同步 | 不是 App 行为                |
| `time.apple.com`                             | 系统时间同步          | 不是 App 行为                |
| `configuration.apple.com`                    | 系统配置下发          | 不是 App 行为                |
| 你 App 的域名 / 任何第三方 API               | **就是它**            | ❌ 这里出现一条，豁免即告失败 |

**判定方法**：抓包里按「进程 / Process」过滤，只看你自己那个 App 进程的流量。系统进程的流量全部排除。

---

## 1. 静态证据：代码层不画出网的网

> 这一节你不需要自己写代码。把下面每条丢给 AI（Cursor / Claude / WorkBuddy 都行），让它扫工程然后**贴真实输出**给你。

### 1.1 依赖清单（最先做，5 分钟出结果）

| 文件 / File                                      | 看什么 / What to look for     |
| ------------------------------------------------ | ----------------------------- |
| `Package.resolved`（Swift Package Manager）      | 有没有出现在 1.3 黑名单里的库 |
| `Podfile.lock`（CocoaPods）                      | 同上                          |
| `Cartfile.resolved`（Carthage）                  | 同上                          |
| `Frameworks/` 里的 `.xcframework` / `.framework` | 有没有第三方二进制 SDK        |

### 1.2 黑名单（出现即需处理）

| 类别        | 关键词                                                       |
| ----------- | ------------------------------------------------------------ |
| 网络库      | `Alamofire`、`Moya`、`AFNetworking`、`Get`                   |
| 崩溃 / 埋点 | `Firebase`、`Crashlytics`、`Sentry`、`Bugsnag`、`Amplitude`、`Mixpanel`、`Umeng`（友盟）、`TalkingData`、`GrowingIO`、`Sensors`（神策）、`ThinkingData` |
| 广告        | `GDTMobSDK`（广点通）、`Google-Mobile-Ads`、`AppLovin`、`Pangle`（穿山甲）、`UnityAds` |
| 推送        | `JPush`（极光）、`UMengPush`、`Getui`（个推）                |
| 后端 SDK    | `LeanCloud`、`Bmob`、`AVOSCloud`、`Supabase`、`FirebaseFirestore` |
| 远程图片    | `SDWebImage`、`Kingfisher`（**本地图不用它们就不会出现；出现了要确认没在加载远程 URL**） |
| 支付 / 登录 | `WechatOpenSDK`、`AlipaySDK`、`WeiboSDK`                     |

> ⚠️ 注意「有库 ≠ 用了」：`Kingfisher` 装在里面但只加载 Bundle 内图片，实际不出网。但**向审核解释成本很高**，最省事的处理是发版前删掉不用的依赖。

### 1.3 全局搜索出网 API

在 Xcode 里 `Cmd+Shift+F`，或让 AI 跑 grep，逐个确认「零命中」或「命中但未调用」：

```
URLSession
URLRequest
dataTask
downloadTask
uploadTask
NSURLConnection
CFStreamCreatePairWithSocketToHost
NWConnection
NWListener
WKWebView
WKWebViewConfiguration
SFSafariViewController
ASWebAuthenticationSession
CKContainer            // CloudKit
CKDatabase
NSUbiquitousKeyValueStore   // iCloud 键值同步
SKPaymentQueue         // 内购
```

**处理原则**：命中了不是罪，**没被调用才是清白**。把命中清单列出来，标明每个的调用位置和参数（是否只走 `file://` 或 `Bundle`）。

### 1.4 Info.plist 四个必查项

| Key                                                          | 出现说明                                                     | 处理                       |
| ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------- |
| `NSAppTransportSecurity`                                     | ATS 例外配置。有 `NSAllowsArbitraryLoads = true` 或域名例外 → 说明原本要连 HTTP | 删掉；删不掉说明确实在联网 |
| `NSUserTrackingUsageDescription`                             | 请求 ATT 追踪授权 → 一定有归因 / 广告 SDK                    | 删                         |
| `FirebaseAppDelegateProxyEnabled` / `GADApplicationIdentifier` / `FacebookAppID` | 已集成 Firebase / AdMob / Facebook SDK                       | 删                         |
| `UIBackgroundModes` 里含 `remote-notification`               | 远程推送 → 要连 APNs                                         | 删                         |
| `LSApplicationQueriesSchemes` 含 `weixin` / `alipay`         | 有微信 / 支付宝跳转                                          | 确认是否真用               |

### 1.5 Entitlements 与 Capabilities

打开 `*.entitlements` 和 Xcode → Target → Signing & Capabilities，逐项确认**关闭**：

- [ ] Push Notifications（`aps-environment`）
- [ ] iCloud / CloudKit（`com.apple.developer.icloud-services`）
- [ ] In-App Purchase
- [ ] Background Modes → Remote notifications
- [ ] Associated Domains（`com.apple.developer.associated-domains`）
- [ ] Network Extensions

> **这一项最容易翻车**：Xcode 新建工程时勾了 iCloud，后面忘了关，豁免直接不成立。

### 1.6 App 内有没有出网入口

- [ ] 有没有 `UIApplication.shared.open(URL)` 打开外部浏览器 / 微信
- [ ] 有没有可点击的 http 链接（数据来源标注、致谢、帮助页）
- [ ] 分享功能是否只走 `UIActivityViewController`（系统 Share Sheet，本地生成图 → 系统处理，不算 App 出网）

**建议**：数据来源、致谢一律做成**纯文本不可点**。留链接对产品没增益，对豁免是风险。

---

## 2. 动态证据：抓包抓出「一片空白」

### 2.1 阳性对照（关键一步，别省）

直接抓包看到空白 ≠ 证明无流量，可能是**代理没生效**。所以先做对照：

1. 开 Charles / Proxies / mitmproxy，手机装上代理证书
2. **先用一个确定会联网的 App**（Safari 打开任意网页）走一遍
3. 抓到 Safari 的请求 → **证明代理链路是通的**
4. 再切回你的 App 跑完整流程

> 这一步就是控制变量：**「空白」只有在「对照组有输出」的前提下才有证明力。** 没有对照的空白截图，审核不认。

### 2.2 全功能走查（飞行模式 + 抓包各跑一遍）

按产品实际路径逐项打勾，**每一条都要跑**：

- [ ] 冷启动（首次安装后第一次打开）
- [ ] 冷启动（已有数据后打开）
- [ ] 浏览主列表 / 卡片墙
- [ ] 搜索 / 筛选
- [ ] 新建一条记录（填写 + 保存）
- [ ] 编辑已有记录
- [ ] 删除记录
- [ ] 生成分享图（F8）
- [ ] 通过 Share Sheet 分享到微信 / 相册
- [ ] 设置页 / 关于页
- [ ] 后台切换再回前台
- [ ] 杀进程后重开

两种环境各跑一次：

- **A. 飞行模式**（Wi-Fi + 蜂窝全关）：功能应完全可用，无空白、无转圈、无 Toast 报错
- **B. 正常联网 + 抓包**：App 进程**零出网请求**

### 2.3 要留的证据（申诉材料）

| 证据                           | 怎么留                           |
| ------------------------------ | -------------------------------- |
| 抓包截图（App 进程过滤后为空） | 带时间戳，窗口标题显示 App 名字  |
| 阳性对照截图（Safari 有请求）  | 同一会话里，证明工具有效         |
| 飞行模式全功能可用录屏         | 30-60 秒，覆盖新建 → 保存 → 分享 |
| 依赖清单截图                   | `Package.resolved` 全文          |
| Entitlements 截图              | 全部关闭的状态                   |

---

## 3. 商店侧证据：让三个地方口径一致

这三处任何一处自相矛盾，审核都会回头质疑你的豁免声明。

| 位置 / Where                     | 要填成 / Set to                                              |
| -------------------------------- | ------------------------------------------------------------ |
| ASC → App 隐私 / App Privacy     | **Data Not Collected / 不收集数据**                          |
| 隐私政策页（Privacy Policy URL） | 内容必须与「不收集」自洽。**不能出现"我们使用第三方分析服务""我们会记录您的使用行为"这类句子** |
| App 内购 / In-App Purchases      | 列表为空                                                     |
| App 内隐私弹窗（首次启动）       | 只声明本地权限（相册写入等），不提数据上传                   |

> **隐私政策页放哪里不用备案**：如果托管在 GitHub Pages、Vercel、境外对象存储，域名不在中国大陆 → 该页面本身不需要 ICP 备案。**这是「境外托管」和「境内接入」的分界，别混。**
> 但反过来：如果为了让它"看起来正规"去买了个境内域名解析，那这个域名就要备案了。**别为了美观给自己造一个备案义务。**

---

## 4. 豁免申诉材料包

### 4.1 必备要素

- [ ] 苹果官方豁免声明模板（ASC 联系客服通道索取 / 审核申诉页下载）
- [ ] **Team ID**（Apple Developer 后台 → Membership）
- [ ] **App ID**（ASC → App 信息里的数字 ID，不是 Bundle ID）
- [ ] **Bundle ID**
- [ ] 开发者主体名称（个人：姓名与身份证一致）
- [ ] 本人手写签字 + 身份证号 + 日期
- [ ] 扫描成 PDF（若被拒，改传照片）

### 4.2 正文话术（英文，可直接粘贴改）

> This app performs no network communication of any kind. All functionality — data storage, search, image generation, and sharing — executes entirely on-device using a local database. The app contains no backend, no analytics SDK, no crash-reporting SDK, no advertising SDK, and no remote configuration. Its entitlements declare no push notifications, no iCloud/CloudKit, and no in-app purchases. App Transport Security has no exceptions configured. A packet capture of the app process during a full functional walkthrough (cold launch, create, edit, delete, share) shows zero outbound requests. The app remains fully functional in Airplane Mode.
>
> Attached: (1) signed exemption statement, (2) packet capture screenshots with a positive control, (3) Airplane Mode walkthrough recording, (4) dependency list, (5) entitlements screenshot.

### 4.3 提交路径

App Store Connect → 联系客服 / Contact Us → App 审核 / App Review → 申诉或"我的 App 被拒绝" → 上传 PDF。

周期：约 **3 个工作日**。

---

## 5. 破功雷区：每次发版前重跑第 1-2 节

以下任何一项加进来，豁免前提当场失效，必须补备案（2-4 周，赶不上发版）：

| 雷                               | 为什么破功     | 替代方案                                     |
| -------------------------------- | -------------- | -------------------------------------------- |
| iCloud / CloudKit 同步           | 联网           | 先做本地导出 / 手动备份文件                  |
| 崩溃统计（Sentry / Crashlytics） | 联网           | 靠 TestFlight 反馈 + 本地日志                |
| 远程配置 / 功能开关              | 联网           | 打包时烧死配置                               |
| 远程字体 / 图片下载              | 联网           | 全部打包进 Bundle                            |
| WebView 打开帮助页 / 协议页      | 联网           | 本地 Markdown 渲染                           |
| 广告 / ATT / 归因                | 联网 + 追踪    | 不做                                         |
| 在线地图瓦片                     | 联网           | 用离线底图或纯矢量自绘                       |
| 内购                             | 要连 App Store | 一次性买断也要内购 → 那就得走备案 + 企业主体 |

> ⚠️ **一个决策岔路**：如果将来一定要收费，就不是"补个功能"的问题——个人备案不允许商业化，得换企业主体 + 走备案，整套重来。**在动手加任何联网功能之前，先确认这一步。**
