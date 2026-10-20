# 出题规范（SPEC）· DSA_Cangjie_topic

> 本文件是**唯一施工标准**。所有题目的题面格式、数据格式、验证流程都以本文件为准；
> 课程内容（关卡主题、题号、标题、考察点）以 `..\大纲.md` 为准，两者都不许自行改动。
> 遇到"大纲里的题在仓颉 1.0.5 上做不出来/不好判"，**停下来报告**，不要改题号或砍题。

---

## 1. 工作目录与写入边界

工作根目录：`drills\DSA_Cangjie_topic`（绝对路径见下）

```
C:\Users\admin.PC-20241201YZZW\Desktop\ICT\drills\DSA_Cangjie_topic\
├─ 大纲.md                  ← 只看不改（课程大纲）
├─ judge.ps1 / 自助判题.cmd / messages.json  ← 只看不改（判题器）
├─ problems\<ID>\          ← ★ 你写的：题面.md + in\ + out\
├─ _build\check.py         ← 只看不改（数据自检）
├─ _build\gen_out.ps1      ← 只看不改（用参考实现产出 out\）
├─ _build\ref\<ID>.cj      ← ★ 你写的：参考实现（交付时会被删除，不要写进 answers\）
└─ _build\gen\<ID>.py      ← ★ 你写的：数据生成脚本（会被删除）
```

**只允许写**：`problems\D<关>-<字母>\`、`_build\ref\D<关>-<字母>.cj`、`_build\gen\D<关>-<字母>.py`。
**绝对不要写**：`judge.ps1`、`messages.json`、`大纲.md`、`_build\check.py`、`answers\`、别人负责的关卡。
**不要** `git commit` / `git checkout` / 删除他人文件。

题号规则：关卡号 `D1`…`D18`，每题字母 `A`/`B`/`C` = 基础，`D` = ★挑战。目录名、题面标题、参考实现文件名、生成脚本名**全部用同一个 ID**。

环境：Windows + PowerShell 5.1；`cjc` 在 PATH（**Cangjie Compiler 1.0.5**）；Python 用 `D:\python\python.exe`。

---

## 2. 每题必须产出 4 件东西

| 产物 | 路径 | 说明 |
|---|---|---|
| 题面 | `problems\<ID>\题面.md` | UTF-8 **无 BOM**，LF 换行，模板见 §3 |
| 输入 | `problems\<ID>\in\01.txt` … `05.txt` | 固定 **5 个用例**（见 §4） |
| 期望输出 | `problems\<ID>\out\01.txt` … `05.txt` | **由参考实现产出**，不许手写 |
| 参考实现 | `_build\ref\<ID>.cj` | 仓颉源码，必须 `judge.ps1` 全绿（见 §6） |

外加数据生成脚本 `_build\gen\<ID>.py`（见 §5），用于重跑与复核。

---

## 3. 题面模板（逐字照抄结构，只换内容）

````markdown
# D3-B · 后缀表达式求值

**关卡**：D3 · 栈
**提交文件**：`answers/D3-B.cj`

> 一句话说明这题要你干什么，以及本关要考的那个点。（可换行，最多三行）

## 知识点

- 每条一个点，用仓颉里的真实名字（如 `ArrayList` 尾部当栈顶、`Int64.parse`、`slice(start, len)`）
- 4–6 条，只写本关知识点，不要泛泛而谈

## 输入

第一行……（把输入的每一部分都说清楚：几行、几个数、分隔符是什么）

**数据范围**：1 ≤ n ≤ 2×10⁵；-10⁹ ≤ aᵢ ≤ 10⁹

## 输出

输出几行、每行什么格式。**多解/无解/重复答案**必须明确写清：输出哪一个、怎么排序、并列怎么办。

## 样例

**样例 1**

```
输入：
<与 in/01.txt 逐字符一致>
输出：
<与 out/01.txt 逐字符一致>
```

**样例 2**

```
输入：
<与 in/02.txt 逐字符一致>
输出：
<与 out/02.txt 逐字符一致>
```

## 提示

- 仓颉侧的具体提示（哪个 API、哪个坑）
- 复杂度提示（这题 O(?) 才能过）

---

## 自测

```
自助判题.cmd -Problem D3-B
```
````

**硬性要求**

- `**关卡**` 一行的关卡名必须与 `大纲.md` 里的关卡标题逐字一致（如 `D3 · 栈`）。
- `**提交文件**` 一行必须写成（把 `<ID>` 换成真题号）：`` **提交文件**：`answers/<ID>.cj` ``。
- **`## 知识点` 小节必须有**，这是本库与普通题库的区别。
- 题面里**不许出现参考实现**，也不许写"答案就是……"。
- 题面全部中文说明，**但程序输出必须是 ASCII**（见 §8）。

---

## 4. 用例设计规则（固定 5 个，绝不随机凑数）

| 用例 | 作用 | 规模 | 要求 |
|---|---|---|---|
| `01.txt` | 样例 1：**能一只手算出来** | 最小 | 题面第一个样例，读者照着能验证自己理解对了 |
| `02.txt` | 样例 2：**边界** | 最小 | n=1 / 空结果 / 全相同 / 不存在答案 等边界情形 |
| `03.txt` | 中等随机 | ~10–100 | 覆盖一般情形，用固定 seed 生成 |
| `04.txt` | **专治易错点** | 小~中 | 极值（-10⁹/-10⁹ 边界）、重复元素、并列、不可达、需要 Int64 的情形 |
| `05.txt` | 规模压测 | **达到题面声明的上界** | 必须让 O(n²) 超时、O(n log n)/O(n) 稳过；运行 ≤ 1.5 s |

补充规则：

- 声明的 `n` 上界**必须**在 `05.txt` 里真的达到（题面写 2×10⁵ 就放 2×10⁵）。不达标 = 虚假复杂度。
- 单个 `.txt` ≤ 8 MB；大数组用**一行或少量几行**存，不要 20 万行。
- 每行**不留行尾空格**，文件末尾**恰好一个换行**，**LF**，**无 BOM**。
- 输出不允许有空行结尾，也不允许依赖浮点误差（需要浮点就固定 `.2` 之类的格式）。

---

## 5. 数据生成脚本规范

```python
# _build/gen/D3-B.py
import os, random
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PID  = 'D3-B'
PROB = os.path.join(ROOT, 'problems', PID)

def write_case(idx, text):
    d = os.path.join(PROB, 'in'); os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, '%02d.txt' % idx), 'w', encoding='utf-8', newline='\n') as f:
        f.write(text)

rnd = random.Random(20260101)   # 固定 seed，保证可重跑
# ... 逐用例生成 ...
```

- **只生成 `in\`**，`out\` 一律由 `gen_out.ps1` 从参考实现产出（避免"手写答案"与"程序行为"不一致）。
- `encoding='utf-8'` + `newline='\n'`（`newline` 必须显式给，否则 Windows 会写 CRLF）。
- 固定 `seed`，同一脚本重跑结果必须一致。
- 生成后立刻跑一遍：`D:\python\python.exe _build\gen\<ID>.py`。

---

## 6. 参考实现规范（`_build\ref\<ID>.cj`）

- **必须是本题目标算法**（该 O(n log n) 就写 O(n log n)），不许"先暴力再祈祷数据小"。
- 只用**标准库**（`std.env` / `std.convert` / `std.collection` / `std.sort` / `std.math` / `std.unicode`），不引第三方、不读文件、不联网。
- 必须有 `main() { ... }`，从 stdin 读、往 stdout 写，退出码 0。
- 编译无 error（warning 可以有，但最好清掉）。
- 最大用例耗时 ≤ 1.5 s（本机实测）。

验证一条题（在 `DSA_Cangjie_topic` 目录下）：

```powershell
# 1) 生成 in\
D:\python\python.exe _build\gen\D3-B.py

# 2) 用参考实现产出 out\（会打印每个用例耗时）
powershell -NoProfile -ExecutionPolicy Bypass -File _build\gen_out.ps1 -Problem D3-B

# 3) 判题器回放（真正的验收）
powershell -NoProfile -ExecutionPolicy Bypass -File .\judge.ps1 -Problem D3-B -Source _build\ref\D3-B.cj

# 4) 题面/数据机械自检（样例是否与 01/02 一致、BOM/CRLF/命名）
D:\python\python.exe _build\check.py D3-B
```

四条都过 = 这题完成。第 3 步出现 `用例 xx 答案错误` 说明 `out\` 与参考实现不一致，重跑第 2 步；
第 4 步 `样例 k 的输入与 in/0k.txt 不一致` 说明题面里的样例抄错了，改成文件内容。

---

## 7. 已实测的仓颉 API（cjc 1.0.5，**这些是实测结论，别再猜**）

| 想干什么 | 正确写法 | 坑 |
|---|---|---|
| 读一行 | `getStdIn().readln().getOrThrow()`（`import std.env.*`） | 返回 `?String`；**空行是 `Some("")`**，不是 `None` |
| 读到 EOF | `var c = getStdIn().readln()` + `while (let Some(line) <- c)` 或 `while (c.isSome())` | — |
| 切分一行 | `line.trimAscii().split(" ")` → 可直接 `.size`、可 `for (p in parts)` | 连续空格产生空串，要 `if (p.size == 0) { continue }` |
| 解析整数 | `Int64.parse(s)` | 不容忍空白/`+`；`trimAscii()` 先做 |
| 升序排序（数组） | `sort(a)` / `sort(a, descending: true)`（`import std.sort.*`） | — |
| 自定义比较器 | `sort(a, by: {x: T, y: T => ...})`，`by:` **是命名参数** | 老的 `sortBy` 已 deprecated，别用 |
| 比较器返回值语义 | 返回**自然序**（`x>y` 就返回 `Ordering.GT`）→ 结果**升序** | 想要降序：把 GT/LT 反过来，或用 `descending: true` |
| ArrayList 排序 | `sort(list, by: {...}, stable: true)` | `stable!` 默认 false |
| 结构体/元组排序 | 元组可直接 `sort(entries, by: {x: (String, Int64), y: (String, Int64) => ...})`，取元素 `x[0] x[1]` | 多键排序就写在一层 if-else 里 |
| 遍历 HashMap | `for ((k, v) in m) { ... }` | **遍历顺序不稳定**，输出前必须自己排序 |
| HashMap 读写 | `m.add(k, v)` / `m[k] = v` / `m.get(k): ?V` / `m.contains(k)` | 没有 `put`/`containsKey`；`get` 返回 Option，取值用 `.getOrThrow()` 或 `?? d` |
| ArrayList | `add` / `size` / `l[i]` / `remove(at: i)` / `insert(i, x)` | 没有 `append`（那是 StringBuilder 的） |
| 定长数组 | `Array<Int64>(n, repeat: 0)`、`arr.size`、`arr.slice(start, len)` | `slice` 第二参是**长度** |
| 深拷贝 | `arr.clone()`（`ArrayList` 用 `ArrayList<T>(list)` 或 `clone()`） | 值类型赋值即拷贝，但集合只拷引用 |
| 整数格式化 | `n.format("03")` → `042`、`(-7).format("03")` → `-07` | 负号要加括号：`-7.format(...)` 会编译报错 |
| 浮点格式化 | `f.format(".2")` | **`.2f` 会抛异常**；舍入是"四舍六入五取偶" |
| 字符串 | `s.size` 是**字节数**；字符数用 `s.toRuneArray().size`；`s.trimAscii()`；切片 `s[0..5]` | 没有 `substring`、没有 `trim()` |
| 数学 | `import std.math.*`，有 `abs/sqrt/ceil/floor/round`，**没有** `max`/`min` | 自己写一行比较 |
| 栈 / 队列 / 堆 | 标准库**都没有**：栈用 `ArrayList` 尾部、队列用数组+首尾指针、堆手写 | 这正是 D3/D4/D13 的教学点 |

需要更多仓颉知识时，加载技能 **`cangjie-coding`** 查标准库与语言特性，**不要凭记忆写**；写完必须编译验证。

---

## 8. 输出格式规范（判题是逐字符比较）

1. **程序输出禁止中文/全角符号**，一律 ASCII（`sum=12`、`YES`、`a b c`）。
2. 每行末尾**不输出空格**；整个输出**末尾不留空行**。
3. 多个值一行时用**单个空格**或**半角逗号**，题面里写死，不要混用。
4. 顺序不确定的结果（HashMap、并查集根、图邻居）必须**先排序**再输出，题面里写明排序规则。
5. 有多解时题面必须写清"输出字典序最小 / 下标最小的那一个"，否则无法判题。
6. 布尔值用 `true`/`false`；空结果用 `none` 或 `-1`，题面里明确。

---

## 9. 自己不要做的事

- 不要改 `judge.ps1` / `messages.json` / `check.py` / `gen_out.ps1`（发现 bug 就报告）。
- 不要在 `problems\` 里放参考实现、草稿、`.exe`、`.cjo`、临时文件。
- 不要把 `answers\` 填满（交付时 `answers\default\src` 是空的）。
- 不要为了让数据过而弱化数据（删掉压测用例 = 复杂度考不出来）。
- 不要复制别的题的数据改个标题就交（每题的输入结构必须符合它自己的题面）。

---

## 10. 交付报告格式（做完在回复里贴）

```
关卡 D3（栈）：4/4 完成
| 题号 | 标题 | 用例数 | 参考实现 judge | check.py | 最大用例耗时 | 复杂度 |
|---|---|---|---|---|---|---|
| D3-A | 括号匹配 | 5 | 5/5 通过 | ok | 61ms | O(n) |
...
遗留问题：无 / <具体说明>
```

**验收口径**：`check.py` 全 `ok`，且每题 `judge.ps1 -Problem <ID> -Source _build\ref\<ID>.cj` 输出"本题全部用例通过"。
