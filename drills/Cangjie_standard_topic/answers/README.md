# 答题区

> 日常不用手动往这里拷 —— **双击 `..\自助判题.cmd`，输入关卡号，判题前会自动同步。**

## 你写代码的地方

```
answers\default\src\<题号>.cj        ← 就写在这里
```

文件名 = 题号，例如：

```
answers\default\src\B4-A.cj
answers\default\src\B4-B.cj
answers\default\src\B17-E.cj
```

判题时这些文件会被复制到 `answers\` 下（就是本目录），然后编译判题。

## 判题

双击 `..\自助判题.cmd`，输入关卡号（如 `4`），回车。

带参数也可以：

```
自助判题.cmd -Level 4
自助判题.cmd -Problem B4-C
```

## 规矩

判题只告诉你「输入 / 期望输出 / 你的输出」，**不会给参考实现**。

## 注意

- `.cj` 源码**带不带 BOM 都能编译**（已实测），不用操心
- 但**别用会写 BOM 的方式造测试输入文件**，BOM 会让第一行前面多一个字符，`Int64.parse` 当场抛异常
- 题库自带的 `problems\*\in\*.txt` 都是无 BOM 的，放心用
- 读入的两种写法别搞混：顶层 `readln()` 返回 `String`（EOF 得到空串）；`getStdIn().readln()` 返回 `?String`（EOF 得到 `None`）

详细说明见 `..\使用说明.md`。
