---
name: china-app-icp-and-app-store-mainland
description: >-
  Use when preparing China mainland APP ICP filing (App 备案 / ICP 备案), a
  website ICP alongside an app domain, or listing an iOS app on the China App
  Store with an ICP number — first decide whether filing is even required
  (zero-network apps can request an Apple ICP exemption), then coach the next
  form step. 触发词：App备案、APP备案、ICP备案、工信部备案、通信管理局、备案号
  -nA、个人开发者备案、App Store 中国区上架、中国大陆上架、ICP 豁免、零联网 App。

---

# 中国大陆 App 备案 + App Store 中国区上架

# China Mainland App ICP Filing + App Store Listing

> 字段名一律给「中文 / English」双语，因为备案表单是中文、App Store Connect 常是英文。对不上号的时候以你眼前那个界面为准。
> Field labels are given as "中文 / English" because the MIIT filing forms are Chinese while App Store Connect is usually English.

---

## 第一步：先分流，别急着备案 / Step 0 — Route First, Don't File Blindly

**判定标准不是「上不上中国区 App Store」，而是「App 有没有境内网络请求」。**
**The test is not "am I listing on the China App Store" — it is "does the app make any network request to mainland China".**

先问清三件事 / Ask three questions:

1. App 运行时会发网络请求吗？/ Does the app make network requests at runtime?（启动埋点 analytics、崩溃上报 crash reporting、第三方 SDK、云端配置 remote config、iCloud/CloudKit 同步、登录 login、加载任何 URL）
2. 有没有后端域名，且该域名 / 服务器位于中国大陆？/ Is there a backend domain, and is the server inside mainland China?
3. App 内有没有付费、内购、广告、会员？/ Any payment, in-app purchase, ads, or subscription?

| 情形 / Case                                                  | 是否需 App 备案 / Needs filing?                              | 走哪节 / Go to                                 |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------- |
| 完全零联网，全部功能本地运行 / Fully offline, all logic on-device | 不需要 / No                                                  | **A 节 / Section A**                           |
| 有联网但后端在境外 / Networked, backend overseas（HK/abroad） | 严格意义不受工信部约束；但隐私政策页、客服页若用境内域名，该域名仍须备案 / Not bound by MIIT, unless your privacy-policy or support page sits on a mainland domain | 先试 **A**，兜底 **B** / Try A, fall back to B |
| 有联网 + 后端在境内 / Networked + mainland backend           | **必须 / Mandatory**                                         | **B 节 / Section B**                           |

> ⚠️ **一条硬线 / Hard line**：豁免的唯一判据是「零境内网络接入」。只要存在一次联网行为——哪怕只是启动页埋点——豁免 100% 驳回。不要虚假申报。
> The only basis for exemption is **zero mainland network access**. One single request — even a splash-screen analytics ping — fails it 100%. Never misdeclare.

---

## A. 零联网 App：申请 ICP 豁免 / Offline Apps: Apple ICP Exemption

1. **自证零联网 / Prove it yourself first**（别让审核替你发现 / don't let review find it）
   → **完整操作清单见 [`references/zero-network-proof.md`](references/zero-network-proof.md)**，含依赖黑名单、出网 API 搜索列表、Info.plist / Entitlements 必查项、抓包对照方法与申诉材料包。
   三条主线 / three tracks：

   - **静态 / Static**：依赖清单无网络 SDK；全局搜索 `URLSession` / `CloudKit` / `WKWebView` 零命中；`Info.plist` 无 ATS 例外；Entitlements 无 Push / iCloud / IAP
   - **动态 / Dynamic**：飞行模式全功能可用（无空白、无转圈）；抓包 App 进程零出网
   - **对照 / Positive control**：⚠️ 先让一个确定联网的 App（Safari）在同一次抓包会话里有输出，证明代理链路有效——**没有对照的"空白"没有证明力，审核不认**

2. 取苹果官方豁免声明模板，填写 / Fill Apple's exemption statement template：

   - **Team ID**（开发者团队 ID）+ **App ID**（数字 App ID）+ **Bundle ID**（包标识符）+ 开发者主体信息 / developer entity info

3. 个人开发者 / Individual：**本人手写签字 + 身份证 + 日期**（PDF 常被拒，传照片或扫描件 / submit photo or scan, PDFs get rejected）

4. 提交路径 / Submit：App Store Connect → 联系客服 / Contact Us → 审核申诉 / App Review appeal，上传 PDF，正文写明 / state plainly：

   > "All app functionality runs entirely on-device. There is no network access to mainland China or any remote server."

5. 周期 / Timeline：约 **3 个工作日 / ~3 business days**

> ⚠️ **证据等级 / Evidence grade**：豁免口径主要来自服务商与开发者实务经验，并非苹果官方文档明文；ASC 勾选中国大陆 territory 时仍会出现 ICP 号字段。
> The exemption path comes from vendor / developer practice, **not** from published Apple documentation. ASC still shows an ICP field when you select Mainland China.
> 所以策略是「**先把零联网做成可举证的事实 → 再申诉 → 被驳回再补 B 节**」，不是赌。
> Strategy: **make zero-network an evidenced fact → appeal → file (Section B) only if rejected.** Do not gamble.

> ⚠️ **会破功的动作 / What breaks it**：加 iCloud / CloudKit 同步、加崩溃统计、加任何网络请求 / adding any sync, crash reporting, or network call. 届时豁免前提不成立，必须补备案 / the exemption premise dies, filing becomes mandatory.

---

## B. 需要备案：APP 备案流程 / Section B — The Filing Itself

### 两套号别混 / Two different numbers, don't mix them up

| 类型 / Type              | 格式 / Format             | 例 / Example           |
| ------------------------ | ------------------------- | ---------------------- |
| 网站备案号 / Website ICP | `省简称+ICP备+数字+号-1`  | `粤ICP备12345678号-1`  |
| APP 备案号 / App filing  | `省简称+ICP备+数字+号-nA` | `粤ICP备12345678号-2A` |

同一主体、同一域名，网站与 APP 常可在一张订单里一起备，但**号码是两个**。个人主体与企业主体规则不同，以接入商（云厂商）当期公示为准。
Same entity and domain can usually be filed in one order, but you get **two separate numbers**. Rules differ for individuals vs. companies — follow your access provider's current published requirements.

### 前提条件 / Prerequisites（缺一项就提交不了 / missing one blocks submission）

| 项目 / Item                                                  | 要求 / Requirement                                           |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 域名实名 / Domain real-name                                  | 已完成实名认证，且**注册人与备案主体一致** / verified, registrant matches filing subject |
| 服务器 / 接入商 · Server · **access provider (接入商)**      | 境内云资源，包年包月 **≥3 个月**、有公网 IP。**境外 VPS / Vercel / 海外 SaaS 不能作为接入** / mainland cloud resource, prepaid ≥3 months, public IP. Overseas VPS / Vercel / foreign SaaS **do not qualify** |
| 主体实名 / Entity verification                               | 在该云厂商完成实名 / completed at that cloud provider        |
| **备案服务号 / Filing service code（授权码 / authorization code）** | 买了云资源后要在控制台生成；一个实例通常可申请约 5 个。**没有它进不了提交页** / generate in console after purchase; ~5 per instance; **no code, no submission page** |
| App 展示名 / App display name                                | 图标下方文字稳定；ASC 简体中文名与备案名一致 / the label under the icon; must match ASC's Simplified Chinese name |
| Bundle ID                                                    | iOS 唯一标识 / unique app identifier                         |
| **公钥 / Public key**                                        | 从 **Distribution 证书**提取 / extract from your Distribution cert |
| **指纹 / Fingerprint（SHA-1）**                              | 表单写 MD5 时，Apple 填 SHA-1 的 hex / when the form says MD5, give the SHA-1 hex for Apple |
| App 图标 / App icon                                          | 华为云口径 ≤100KB / ≤100KB on Huawei Cloud                   |
| 隐私政策页 / Privacy policy URL                              | 可访问。托管在 GitHub Pages / Vercel / 境外对象存储时该页面**不需备案**（境外托管 ≠ 境内接入）；但若为它买了境内域名解析，那个域名要备案 / reachable. Hosted overseas → the page itself needs no filing; a mainland domain pointing at it does |
| 支持页 / Support URL                                         | 可访问 / reachable                                           |

### 表单字段对照 / Form Field Map

| 中文字段             | English field               | 怎么填 / How to fill                                         |
| -------------------- | --------------------------- | ------------------------------------------------------------ |
| App 名称             | App name                    | 安装在设备上、图标下方显示的名称 / the label under the icon on device |
| App 图标             | App icon                    | 上传图片，≤100KB / upload image                              |
| App 服务内容         | App service category        | 从官方目录选（生活服务 / 休闲娱乐 / 餐饮服务…）；无精准匹配选相近项 + 备注写清真实用途 / pick nearest from the official catalogue, explain real use in remarks |
| 域名（或子域名）     | Domain / subdomain          | 用到几级备几级，最多四级 / file to the level you actually use, max 4 levels |
| 关联的云 IP          | Associated cloud IP         | 由验证资源自动生成 / auto-generated from the verified resource |
| 是否提供 SDK 服务    | Do you provide SDK services | 把功能打包成 SDK 供他人调用才填「是」，一般「否」 / Yes only if you ship an SDK for third parties |
| 是否应用 SDK 服务    | Do you use third-party SDKs | 用了支付 / 定位 / 登录等公共 SDK 需列服务商与类型 / list vendor + type for payment, location, login SDKs |
| SDK 服务厂商名称     | SDK vendor name             | 未使用可不填 / omit if none                                  |
| SDK 服务类型名称     | SDK service type            | 未使用可不填 / omit if none                                  |
| 选择平台             | Platform                    | iOS / Android / 鸿蒙 HarmonyOS / Linux，一次可多选，每平台分别填特征信息 / multiple allowed, fill traits per platform |
| App 包名 / Bundle ID | Package name / Bundle ID    | 安卓包名与 iOS Bundle ID 不同，分别填 / Android package ≠ iOS Bundle ID |
| 公钥                 | Public key                  | 从 Distribution 证书提取，**绝不凭印象填写** / extract from cert, **never guess** |
| 指纹                 | Fingerprint                 | SHA-1 hex / SHA-1 hex                                        |
| 主办者信息           | Filing subject              | 个人：身份证号；企业：统一社会信用代码 / individual: ID number; company: unified social credit code |
| 主办者负责人         | Subject responsible person  | 姓名、手机号、邮箱，用于短信核验 / name, mobile, email — used for SMS verification |
| 服务内容简介         | Service description         | 一句话说清 App 干什么 / one sentence on what the app does    |

### 时间线 / Timeline（按真实量级规划，别被"20 个工作日"吓住）

| 环节 / Stage                                              | 用时 / Duration                                              |
| --------------------------------------------------------- | ------------------------------------------------------------ |
| 接入商初审 / Provider pre-review                          | 1-2 个工作日 / business days                                 |
| **工信部短信核验 / MIIT SMS verification**                | 初审通过后约 5 分钟收到，**24 小时内必须完成** / arrives ~5 min after pre-review, **must complete within 24h** |
| 省通信管理局审核 / Provincial comms administration review | 7-20 个工作日（20 是上限）/ 7-20 business days (20 is the ceiling) |
| 人脸核验 / Face verification                              | 个人主体必须本人完成 / mandatory for individuals, in person  |
| **合计 / Total**                                          | **最快 3-5 天，常规 2-4 周 / as fast as 3-5 days, typically 2-4 weeks** |

阿里云口径：整体 3-22 个工作日；备案订单有效期 **45 天**，超期自动删除。
Alibaba Cloud: 3-22 business days end to end; filing order expires after **45 days**.

### 拿到号之后：两件必做 / After the number is issued — two must-dos

1. **ASC 回填 / Feed it back to ASC**
   App Store Connect → App 信息 / App Information → 供应情况 / Availability → 中国大陆 / Mainland China → 填 ICP 号 / enter ICP number（`…-nA`）
2. **App 内公示 / Display it inside the app**
   设置 / Settings → 「关于我们」/ About 页静态展示备案号，字体清晰可见。
   Apple review **checks this on a real device**; missing it causes a second rejection.
   苹果审核会**真机抽查**展示位置，不公示会被二次驳回。

---

## C. ASC 与备案的时间配合 / Sequencing with App Review

- 备案与 Apple 审核**可并行**，不必串行等 / filing and review can run in parallel
- 原生包里烧死的 API 域名一旦变更，通常要**发新版本重新审核** / a baked-in base URL change usually needs a new binary + new review
- 推荐顺序 / Recommended order：先用境外后端把当前版本过审 → 备案下来后发下一版指向境内代理
  Ship the current version against an overseas backend → after filing clears, ship the next version pointed at a mainland proxy
- 境内代理的价值不止合规 / The proxy buys more than compliance：避免境内客户端直连被墙的境外 SaaS 域名 / it keeps clients off blocked foreign hostnames

---

## D. 个人主体的硬限制 / Hard Limits for Individuals

个人备案 = **非经营性备案 / non-commercial filing**。
App 内不能有商品交易、会员充值、付费订阅、广告变现，只支持工具查询、图文展示类纯免费应用。
No goods transactions, top-ups, paid subscriptions, or ad monetisation inside the app. Free utility / content-display apps only.

→ **如果产品未来要收费，在备案阶段就得用企业主体**，否则上架后核查会被判违规。
**If the product may ever charge money, file as a company from the start** — post-launch audits do catch this.

企业主体另需 / Company entity also needs：营业执照 / business licence、法定代表人身份证 / legal representative ID、公章 / company seal（承诺书 / commitment letter、核验单 / verification form）。

---

## 常见死法 / Common Ways This Fails

| #    | 死法 / Failure mode                                          | 后果 / Result                                                |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1    | 境外服务器想跳过备案 / "Overseas server, so I'm exempt"      | 苹果不认海外接入资质，照驳回 / rejected                      |
| 2    | 域名实名人与备案主体不一致 / registrant ≠ filing subject     | 直接退 / returned                                            |
| 3    | 备案号填错层级（网站 `-1` 填进 App 栏）/ wrong suffix tier   | 驳回 / rejected                                              |
| 4    | 漏了 App 内公示 / no in-app display                          | 过审后复查被下架 / pulled on audit                           |
| 5    | 备案后换域名、换主体、服务器到期 / domain, entity, or server changes | 备案失效，下次更新再报缺少备案 → 需办**变更备案 / change filing** |
| 6    | 名称 / 版本 / 联系人变更后 **30 日内**未办变更 / missed 30-day change window | 信息不符被要求整改 / forced rectification                    |
| 7    | App 停运后未办**注销备案 / deregistration**                  | 信息与实际长期不符 / flagged                                 |

---

## 术语对照 / Glossary

| 中文        | English                                  | 一句话                                                       |
| ----------- | ---------------------------------------- | ------------------------------------------------------------ |
| 备案        | ICP filing                               | 向工信部登记，不是审批许可 / registration, not a licence     |
| 主办者      | Filing subject                           | 备案的负责人主体：个人或企业 / the responsible entity        |
| 接入商      | Access provider（接入服务商）            | 提供境内服务器、代为提交备案的云厂商 / the mainland cloud provider submitting on your behalf |
| 备案服务号  | Filing service code / authorization code | 云厂商发的提交凭证，一实例约 5 个 / submission token from the cloud provider |
| 管局        | Provincial Communications Administration | 省通信管理局，终审方 / the provincial reviewer               |
| 公钥 / 指纹 | Public key / Fingerprint                 | 从 Distribution 证书提取 / extracted from the Distribution cert |
| 承诺书      | Commitment letter                        | 个人手写签字 + 身份证 + 日期 / handwritten signature + ID + date |
| 经营性备案  | Commercial ICP filing                    | 涉收费、广告需另办 / needed for paid or ad-supported apps    |
| 豁免        | Exemption                                | 零联网 App 向苹果申请免填 ICP / zero-network apps ask Apple to waive the ICP field |

---

## 操作风格 / Coaching Style

- 先给**下一个字段 / 下一个按钮**，再解释为什么 / lead with the next field or button, then explain
- 表单要短文案时，直接给可粘贴的现成文字 / paste-ready copy for short description fields
- **绝不编造证书指纹**，一律从用户的 `.cer` / Distribution 证书提取 / never invent fingerprints
- **绝不声称境外主机满足境内接入** / never claim overseas hosting satisfies mainland access
- 产品特定的 ID、IP、密钥不要写进本 skill，每次从项目当前记录或用户处取 / keep product-specific IDs, IPs and secrets out of this skill

---

## 附件 / Attachments

| 文件 / File                                                  | 何时读 / When to read                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [`references/zero-network-proof.md`](references/zero-network-proof.md) | 走 **A 节（豁免）** 时必读。iOS 端零联网自证清单：依赖黑名单、出网 API 搜索列表、Info.plist / Entitlements 必查项、阳性对照抓包法、申诉材料包、破功雷区 / Required for Section A: the iOS zero-network proof checklist |

