# 华为 ICT 大赛 · 仓颉赛道 备赛计划

> ⚠️ **2026-10-01 起：学习主线已迁出本文件。**
> **主学习计划 = `仓颉学习计划.md`**（基于 CSDN《跟我一起学“仓颉”编程语言》全 85 篇 + 本机 cjc 1.0.5 实测 364 段代码；含 18 模块、十周排期、逐篇优先级与已知坑）。
> **本文件保留为「赛制 / 考点 / 分工 / 环境坑」的参考**：§2.5 考点清单与知识库覆盖矩阵、§5 只能你推进的事、§7 已知坑仍然有效；**§3 的逐周学习主线以 `仓颉学习计划.md` 为准**。

> 制定于 2026-09-28（周一）。省赛 2026 年 12 月，120 分钟 / 3 题（基础 + 算法 + 综合应用）/ 团队实操 / 同分按用时排名。
> 距赛约 10 周，按 **W1 = 9/28–10/4** 起算。

---

## 0. 两个前提事实（先认清，否则计划会偏）

**A. 本机环境 ≠ 比赛环境**
- 本文出现的所有版本号都是**写作时那台机器的实测值**：cjc / cjpm **1.0.5**，stdx **1.0.5.1**
  - ⚠️ **换一台机器请先自查，不要照抄这里的版本号**：`cjc -v`、`cjpm -v`
    （注意 `cjpm -V` 是**错的**，会报 `unknown command '-V'`）
- 参考文档若是 **1.2.0** → 与实现可能有出入，**报错先怀疑版本，别怀疑自己**
- 待办：向老师确认比赛机的 SDK 版本 + 是否能用 stdx

**B. 算法不在知识库里**
- 本机仓颉知识库覆盖的是：语言特性 / 标准库 / 扩展标准库 / 工具链 / 场景示例。**没有算法专题。**
- 结论：**语言和库靠读文档，算法只能靠做题。** 计划里这两条线分开排。

---

## 1. 最高 ROI 动作（本周就启动，贯穿全程）

### 全员考下 HCA-Cangjie Developer 认证
- 每人 **+5 分**，按每人独立满分 100 计 → 3 人 = 15 分
- **全员持证才计入团队总分** → 有一个队友没过，这 15 分全丢
- **报名账号必须与认证账号一致**（这条最容易踩）
- 附带好处：考证过程本身就是最好的语言入门载体

> 行动：本周问老师——认证入口、考期、以及"全员持证"的确切解释。

---

## 2. 总路线：按"到点能上场"倒推

从赛制反推训练重点：

| 赛制特征 | 推论 |
|---|---|
| 120 分钟 | 必须练"读题 3 分钟决定做哪道、放哪道" |
| 3 题覆盖三类 | 不能只刷一类，基础/算法/综合都要有手感 |
| 同分按用时排名 | 不只求 AC，求**快**：模板化、少调试、一次过 |
| 团队实操 | 分工形态决定练法（见第 5 节） |

### 四阶段

| 阶段 | 周次 | 目标 | 验收 |
|---|---|---|---|
| 一 地基 | W1–W2 | 任何题的输入读得进来、输出格式对 | 5 道纯 I/O 题 + 1 次 60 分钟 2 题模拟 |
| 二 骨架 | W3–W5 | 语言 + 基础数据结构够用，基础题不卡 | 每周 1 次 60 分钟模拟 |
| 三 算法/综合 | W6–W8 | 三类题都能上手 | **每周 1 次 120 分钟 3 题全真模拟** |
| 四 冲刺 | W9–赛前 | 压缩用时、固化模板、重刷错题 | 全真模拟稳定 ≥ 60 分 |

### 如果时间不够，砍的顺序
**W5 工具箱 → W4 面向对象 → W6 高级算法**
**永远不砍：W1 的 I/O 底板、每周的模拟赛。**
> 注意：W5 里的 **并发 / 网络 / 包配置是初赛考点**，砍的时候只能砍 W5 的"工具箱"部分，这三个要保住。

---

## 2.5 考纲考点与阶段缺口

> **来源**：第十届华为ICT大赛「仓颉编程赛道 考纲解读与答疑」视频（用户 2026-09-29 提供，43min）。
> ⚠️ 该片是**第十届**，赛制数字（计分比例、日期）**不适用本届**，别照抄。但**考点表可作参考**——两届考纲通常一致。
> **待核实**：本届省赛是否也考理论题？（第十届初赛 = 理论 30min×30% + 编程 120min×70%）

### 考点清单（逐字来自视频，分阶段）

**初赛即考**（≈ 你现在的省赛目标）：
开发环境与工具 · 基础数据类型 · 函数(lambda/闭包/函数式) · struct · enum 与模式匹配 · class/interface 与子类型多态 · 泛型 · **扩展(extension)** · Collection · **包（含 cjpm 工程配置）** · 基础 I/O · **网络编程(std.net / socket / HTTP)** · **并发编程（轻量线程：创建/访问/终止/同步）**

**仅决赛起才考**（省赛阶段不要投入）：
异常处理 · 宏 · 反射与注解 · 跨语言互操作(C) · 三方库使用 · 应用开发实践

### 你现有计划的缺口（对照上表）

> ⚠️ 这是**学习计划**的缺口，**不是知识库缺口**。经用 `cangjie-coding` skill 实测，下列考点本机知识库**均已覆盖**（见下节矩阵），可立刻靠 skill 自学——所以风险比初判低得多。

| 考点 | 计划现状 | 动作 |
|---|---|---|
| **并发编程** | ❌ 完全没有 | **新增**（最硬的缺口） |
| **扩展 extension** | ⚠️ 未列 | W4 补 |
| **泛型** | ⚠️ 未列 | W4 补 |
| **网络编程 socket / std.net** | ⚠️ 只在 W6–8 碰 stdx http | W5–6 补 socket 基础（考点要求的是 socket，不只是 http） |
| **包与 cjpm 配置** | ⚠️ 只碰工具链 | 需理解包定义/访问规则/工程配置 |

已覆盖（无需额外加）：基础数据类型、函数/lambda、struct、enum+模式匹配、class/interface、Collection、基础 I/O。

> **2026-09-29 独立复核结论**：§2.5 的 13 条考点覆盖结论**全部成立（13/13）**，并发 / 网络 / 泛型 / 扩展 / 包 也全部覆盖，无需外部资料。但矩阵里引用的 ID 有 6 条写错、1 条路径不存在（已在本文件中修正）。详见 `KB_COVERAGE_AUDIT.md`（不在本仓库内）。

### 知识库覆盖矩阵（2026-09-29 用 cangjie-coding skill 实测）

左侧 ID 可直接喂给 skill：`python scripts/search_docs.py "<query>"` 或 `--node <ID> --view indexes`。

> ⚠️（2026-09-29 复核）`--node` 只接受**完整 manifest ID**，中间的目录名不能省：例如必须写 `language.concurrency.2-创建线程.2-1-spawn-关键字`，简写成 `2-1 spawn 关键字` 只会得到 `Warning: unknown node`。拿不准时先用 `--query`，再把返回里的 `id:`/`path:` 拿去 `--node`。下表已按复核结果修正。

| 考点（初赛） | 知识库位置（实测命中） | 覆盖 |
|---|---|---|
| 开发环境与工具 | `tools.cjpm` | ✅ |
| 基础数据类型 | `language.basic_data_type` | ✅ |
| 函数 lambda / 闭包 | `language.function`（含 `5-闭包`） | ✅ |
| struct | `language.struct` | ✅ |
| enum + 模式匹配 | `language.enum` | ✅ |
| class / interface + 子类型多态 | `language.class` / `language.interface` / `language.type_system`（子类型关系） | ✅ |
| 泛型 | `language.generic`（9 子页，约束在 `language.generic.7-泛型约束`）+ `language.extend.4-访问规则.4-9-泛型扩展可见性规则` | ✅ |
| 扩展 extension | `language.extend`（直接扩展 / 接口扩展 / 访问规则） | ✅ |
| Collection | `std.collection`（**ArrayList**·ArrayDeque·ArrayQueue·ArrayStack·LinkedList·TreeMap·TreeSet·HashMap·HashSet·HashMapIterator·LinkedListNode；另 13 接口 + 31 顶层函数）+ `std.collection.concurrent`（ConcurrentHashMap · ConcurrentLinkedQueue） | ✅ |
| 包（含 cjpm 配置） | `language.package`（导入 / 隐式 core / 可见性）+ `tools.cjpm` | ✅ |
| 基础 I/O | `std.io` / `std.env`（`ConsoleReader.readln`） | ✅ |
| 网络 std.net / socket / HTTP | `std.net`（**TCP·UDP·Unix Domain Socket·IP/Socket 地址**）+ `stdx.net.http`（Client/Server）+ `examples.network`（URL / HTTP 往返 / WebSocket） | ✅ |
| 并发编程（轻量线程） | `language.concurrency`（`language.concurrency.1-并发概述.1-1-线程模型`、`language.concurrency.2-创建线程.2-1-spawn-关键字`、`language.concurrency.6-访问线程`、`language.concurrency.5-终止线程`、`language.concurrency.4-同步机制.4-1-原子操作` / `.4-2-可重入互斥锁-mutex` / `.4-4-synchronized-关键字`）+ **`examples.concurrency`（6 个现成示例，见 §3-W5）** | ✅ |

**实测确认的知识库缺口（需外部资料）**：
- **算法专题**（排序 / DP / 图 …）——不含，靠做题（与 §0-B 一致）
- **优先队列**——**库本身没有**：`std.collection` 成员仅有上述队列/栈/链表/树集合，无 heap / priority-queue → 用堆要手写（与 §7 一致，已二次实测确认）
- **Cangjie 1.2.0 vs 本机 1.0.5 的差异**——知识库按 1.0.5 为准，与手上的 1.2.0 文档可能有出入

> 结论修正：**并发 / 网络并不是"知识盲区"**，而是"旧计划没排"。两者知识库都全，尤其并发有完整的 `language.concurrency` 章节可直接照学，网络有 std.net + stdx 两套 + 现成 examples。**真正只能靠外部/做题的，是算法专题。**
>
> 追加（2026-09-29 复核）：**外加"优先队列 / 堆"**——库里确实没有，要手写（结论已二次独立确认）。另外并发还有 `examples.concurrency` 6 个现成示例可直接做，不必从零摸索。

### 决赛阶段才用到（2027-03，先记着不投入）

- 应用创作主题 = 基于仓颉开发**智能体应用**（制造/教育/娱乐等场景）
- 评分维度：技术可行性 30% · 创新性 30% · 功能完备性 20% · 性能表现 10% · 代码文档规范性 10%
- 加分项：**自主开发三方库**，按有效代码规模加分，**上限 30 分**

### 官方资源入口（本机禁网，需去能上网的地方取）

- 仓颉官网/下载：`cangjie-lang.cn`
- 仓颉语言社区：`gitcode.com/Cangjie`

---

## 3. 逐阶段内容

左侧是知识库里的对应位置，方便你自己去读。

### W1（9/28–10/4）地基：I/O 与工具链
- `tools/cjpm`、`language/basic_concepts/5-创建-编译和运行仓颉项目`
- I/O 三件套：`std.env.getStdIn` / `readln`、`std.convert` 的 `Int64.parse` / `Float64.parse`
- 格式化输出：`Float64.format(...)`（在 `std.convert` → `Formattable` 接口，**须 `import std.convert.*`**）
  - ⚠️ **原写法 `format(".2f")` 在本机 1.0.5 上会抛异常**（实测：`IllegalArgumentException: Wrong format string '.2f' for 'float' type.`）。文档称浮点可用 `f`/`F` 说明符，实际**不可用**。
  - ✅ **正确写法：`[width][.precision]` 且不带说明符**——`format("1.2")` → 保留 2 位小数，`format("1.4")` → 保留 4 位。宽度必须写 1，否则会补前导空格（`"10.2"` → `      3.75`）。
  - 另两个坑：舍入是**银行家舍入**（`0.125` → `0.12`、`2.675` → `2.67`），且**负零输出 `-0.00`**。OJ 里要让数据保证结果是精确值，别依赖舍入。
  - 详细实测表见 `W1_IO三件套与oj_tpl_v2指导.md`（不在本仓库内） §0.2；证据脚本 `evidence/fmt_evidence.cj`（不在本仓库内）。
- `language/string`：`split` / `trim`
- **三种读法各写通一次**：
  1. 一行空格分隔 N 个数
  2. n 行各一个数
  3. **读到 EOF 为止**（多组数据，最容易漏）
- 产出：你自己的 `oj_tpl` v2 模板
- 我这边：给你 5 道只考 I/O 的题，你写，我跑

### W2（10/5–10/11）语言主线 + 地基收口
- `language/basic_data_type`、`basic_concepts`（表达式 / 控制流 / 函数）
- `language/option` ← **重点**，`??` `?.` `getOrThrow`，OJ 取输入全靠它
- `language/error_handle`：`try/catch`（parse 失败别崩）
- `language/collections/array`、`arraylist`
- `std.sort`：`std.sort.func.sort` 共 **12 个重载** = 3 容器（`Array` / `ArrayList` / `List`）× 4 比较器风格（默认 `Comparable` / `key!` / `lessThan!` / **`by!`**）；`stable!`、`descending!` 是每个重载都带的**公共命名参数**，不是独立重载。别漏 `by!`（`(T,T) -> Ordering`）。
- 验收：60 分钟 2 题模拟

### W3（10/12–10/18）哈希与字符串
- `language/collections/hashmap`、`hashset`：计数、去重、`for ((k, v) in map)` 解构遍历
- `language/string` 系统过一遍：查找 / 替换 / 切片 / 比较
- `std.regex` 正则（华为系爱考）
- 练习：词频统计、Top-K、字符串变换

### W4（10/19–10/25）函数式与面向对象
- `language/function`（lambda / 闭包 / 命名参数）、`struct`、`class`、`interface`、`enum` + `pattern_match`
- **补考点**：**泛型**（定义/约束，精确落点 `language.generic` 与 `language.generic.7-泛型约束`；接口约束写 `where T <: I1 & I2`）、**扩展 extension**（直接扩展 vs 接口扩展的使用场景）——第十届考点明确列出，W4 必须覆盖
- 配套示例：`examples.functions.closure-state`（闭包捕获可变变量的陷阱与安全写法）
- 目的：能把"一条记录"建模成一个类型、把比较规则抽成 lambda
- 提示：用你熟的**汇编 / vtable** 视角理解接口分派——你在这个类比上验证过有效

### W5（10/26–11/1）标准库工具箱
- `std.fs`（文件读写）、`std.time`、`std.random`、`std.math`、`std.process`（命令行参数）
- **补考点①：并发编程（初赛就考，计划原来是空的）**——轻量线程的创建 / 访问 / 终止 / 同步
  - 精读 `language.concurrency` 6 章（2-创建线程 / 6-访问线程 / 5-终止线程 / 4-同步机制 正好对应考点四项）
  - **做完 `examples.concurrency` 的 6 个现成示例**：`spawn-future` / `synchronized-value` / `atomic-counter` / `concurrent-key-counter` / `concurrent-map-insert` / `bounded-channel-lifecycle`——这是零成本补缺口，别自己造轮子
- **补考点②：网络编程 socket 基础**——`std.net` + socket + HTTP 基础（初赛要求；W6–8 的 stdx http 不够）
- **补考点③：包与 cjpm 工程配置**——包定义 / 访问规则 / 工程配置怎么配
- 精读三个场景示例：`examples/collections`、`examples/text`、`examples/failure`
- 验收：60 分钟模拟 + 一次 120 分钟模拟试水

### W6–W8（11/2–11/22）算法 + 综合应用（以模拟赛为主）
- **算法线**（知识库不教，靠题）：模拟 → 排序/贪心 → 前缀和/差分 → 双指针/滑动窗口 → 二分 → 简单 DP → BFS/DFS → 并查集
- **综合应用线**：`examples/json`（stdx）、`examples/files`、`examples/time`（**不是 `examples/datetime`，该路径不存在**）、`examples/network`（stdx http）
  - stdx 项目先跑 `setup_stdx.py --project <dir>`
- **每周六固定一次 120 分钟 3 题全真模拟**（我出题、你作答、我判题）
- 每场模拟后写错题本（你自己写，我不代记）

### W9–赛前 冲刺
- 高频模板各手写 3 遍到不看资料：排序、二分、并查集、图遍历、滑动窗口
- 重刷错题本
- 模拟赛密度提到每周 2 次
- **赛前 3 天减量**：只看模板和错题，不碰新题
- 环境演练：比赛机大概率没有你本机的文档 → 练"只看题面写代码"

---

## 4. 每周固定节奏（按大一课业定，可调）

| 时段 | 内容 |
|---|---|
| 工作日 1h/天 | 30 分钟读知识库一个新主题 + 30 分钟做题 |
| 周六 3h | 模拟赛（限时）+ 复盘 |
| 周日 1h | 错题本 + 补漏 |

约 **9 小时/周**，10 周约 90 小时。

---

## 5. 两件只能你推进的事（我推不动）

1. **组队与分工形态** —— 官方只写"队员独立作答"，需向老师/学习空间核实是哪种：
   - 形态①：三人各做**同一套** 3 题 → 三人必须全面不偏科
   - 形态②：三人**各分一题** → 可按题型分工专精
   - 第三位队友未定。因"全员持证才加分"是团队总分的硬条件，选人时把"**肯考证**"当硬门槛。
2. **确认比赛机 SDK 版本 + 省赛确切日期**（决定冲刺期长度和 stdx API 怎么选）

---

## 6. 我这边的配合方式（沿用你定的规矩）

- **你写，我不写**：只给思路、挑错、跑验证，不给可抄的完整代码
- 你贴报错 → 我先让你自己读一遍，再指位置
- 规划/出题/判题我来；参考实现不留盘，你只能看到"输入 ↔ 期望输出"
- 不做"帮我讲讲第 N 章"这类代读

---

## 7. 已知坑（提前记下）

- **版本差**：文档 1.2.0 vs 本机 1.0.5，语法细节可能对不上
  - **已证实的一处**：`Float64.format(".2f")` 在本机 1.0.5 抛异常，必须写 `format("1.2")`（见 §3-W1）。说明文档与实现确实存在不一致，报错先怀疑版本。
  - ⚠️ 但两版的**完整差异清单仍未核实**：本机无 1.2.0 文档，本轮也无法上网取官方 changelog（检索不可用）。「1.2.0 与 1.0.5 有出入」目前只有上述 1 个实证点，不要当成已系统验证的结论。
- **标准库没有现成的优先队列**：`std.collection` 的全部 **12 个类**（ArrayDeque / **ArrayList** / ArrayQueue / ArrayStack / HashMap / HashMapIterator / HashSet / LinkedList / LinkedListNode / TreeMap / TreeSet / ConcurrentModificationException）中**没有** heap / priority-queue；`std` 与 `stdx` 全域检索 `PriorityQueue`/`BinaryHeap`/堆/优先队列**均 0 命中** → 要堆得自己手写（用 `ArrayList<T>` 自建二叉堆）。注意 `TreeMap`/`TreeSet` 是平衡 BST，**不是堆**（可取 min/max，但没有堆序调整的 O(log n) 语义）。
- **stdx 不在 std 里**：JSON / base64 / http / crypto / log 全在 stdx；且 `stdx.encoding.json` 会隐式依赖 `stdx.serialization.serialization`（带二级后缀那个）
- **OJ 输入格式是最大杀手**：读不进来 = 直接 0 分，所以 W1 先把这块打死
- **并发 / 网络是初赛考点但计划新增**：本机 SDK 1.0.5 的线程与网络 API 可能与你手上的 1.2.0 文档对不上 → 学之前先确认比赛机版本（见 §0-A）

---

## 8. 修订记录（本文件被改过哪些地方）

### 2026-09-29 · 第一轮复核与修订

**改动依据**：`KB_COVERAGE_AUDIT.md`（不在本仓库内）（知识库矩阵独立复核）+ 本机 cjc 1.0.5 实机实验（`evidence/`，不在本仓库内）。

| # | 位置 | 改动 | 依据 |
|---|---|---|---|
| 1 | §2.5 开头 | 新增 `--node` 只接受完整 manifest ID 的说明 | 3 个 ID 实测 `unknown node` |
| 2 | §2.5 泛型行 | `language` 泛型相关 → `language.generic`；扩展可见性 ID 补全中间目录名 | 实测 |
| 3 | §2.5 Collection 行 | 补 `ArrayList`、`std.collection.concurrent`，改为 12 类 + 13 接口 + 31 函数 | 实测 |
| 4 | §2.5 并发行 | 两个 ID 补全为完整路径；补 `examples.concurrency` | 实测 2 个 ID 报 `unknown node` |
| 5 | §2.5 已覆盖段 + 结论修正段 | 补 2026-09-29 复核结论（13/13 成立；算法 + 优先队列才是真缺口） | 审计报告 |
| 6 | §3-W1 格式化输出 | **`format(".2f")` → `format("1.2")`**，并列出负零 / 银行家舍入两个坑 | **实机实验：`.2f` 抛异常** |
| 7 | §3-W2 std.sort | 「四种重载」→ 12 个重载 = 3 容器 × 4 比较器；补 `by!`；说明 `descending!` 是命名参数 | 实测 |
| 8 | §3-W4 补考点 | 泛型补精确落点；补 `examples.functions.closure-state` | 实测 |
| 9 | §3-W5 补考点① | 补 `examples.concurrency` 6 个示例清单 | 实测 |
| 10 | §3-W6–8 综合应用线 | **`examples/datetime` → `examples/time`**（原路径不存在） | 实测 `unknown node` |
| 11 | §7 版本差 | 标注 1.2.0 差异清单**未核实**，只承认 1 个实证点 | 无法上网取 changelog |
| 12 | §7 优先队列 | 结论保留，理由补全为 12 类全清单 + 0 命中证据 | 二次独立确认 |

**仍未解决 / 待你推进**（不属于本轮可代劳范围）：
- §0-A：比赛机 SDK 版本 + 是否可用 stdx — 需问老师
- §1：HCA-Cangjie Developer 认证入口、考期、"全员持证"确切解释 — 需问老师
- §2.5：本届省赛是否考理论题 — 需核实
- §5：组队形态（同一套题 vs 各分一题）+ 第三位队友 — 需问老师/学习空间
- §7：1.2.0 与 1.0.5 的完整差异 — 需去能上网的地方取官方 changelog

### 早期会话的配套文件（⚠️ 不在本仓库内）

> 下面这些是计划写作时在**另一个工作目录**里产生的，**当前仓库里并没有这些文件**。
> 保留在此仅为记录当时的修订依据；引用前请先确认文件是否存在。

| 文件（早期路径） | 用途 |
|---|---|
| `W1_IO三件套与oj_tpl_v2指导.md` | W1 指导材料：三种读法、模板结构要求、输出格式必查项（**不含可抄代码**） |
| `KB_COVERAGE_AUDIT.md` | 知识库覆盖矩阵独立复核报告（18 条矩阵 + 7 条错误 + 逐行修订建议） |
| `evidence/eof_evidence.cj` | `readln` 的 EOF / 空行 / 末尾换行 语义实测脚本 |
| `evidence/fmt_evidence.cj` | `Float64.format` 格式串实测脚本（证明 `.2f` 不可用） |

### 本仓库现有的资产

| 位置 | 用途 |
|---|---|
| `ICT备赛计划.md` | 本文（权威计划） |
| `logs/` | 各阶段课件与说明 |
| `drills/DSA_Advanced_topic/` | 题库 + 判题 harness（双击 `自助判题.cmd` 启动） |
| `drills/DSA_Advanced_topic/problems/INDEX.md` | 题目总表 |
