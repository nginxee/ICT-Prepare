# 答题区

> 日常不用手动往这里拷 —— **双击 `..\judge.cmd`，输入关卡号，判题前会自动同步。**

## 你写代码的地方

```
answers\default\src\<题号>.cj        ← 就写在这里
```

文件名 = 题号，例如：

```
answers\default\src\L7-A.cj
answers\default\src\L7-B.cj
answers\default\src\L7-E.cj
```

判题时这些文件会被复制到 `answers\` 下（就是本目录），然后编译判题。

## 判题

双击 `..\judge.cmd`，输入关卡号（如 `7`），回车。

带参数也可以：

```
judge.cmd -Level 7
judge.cmd -Problem L7-A
```

## 规矩

判题只告诉你「输入 / 期望输出 / 你的输出」，**不会给参考实现**。

## 注意

- `.cj` 源码**带不带 BOM 都能编译**（已实测），不用操心
- 但**别用会写 BOM 的方式造测试输入文件**，BOM 会让第一行前面多一个字符，`Int64.parse` 当场抛异常
- 题库自带的 `problems\*\in\*.txt` 都是无 BOM 的，放心用

详细说明见 `..\使用说明.md`。
