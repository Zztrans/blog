---
title: "ELF concept"
slug: "elf-concept"
description: 
date: 2024-09-08T23:44:23+08:00
image: 
math: true
comments: true
tags: [os]
categories: note
lastmod: 
---

## ELF 概述

**ELF** (Executable and Linkable Format, 可执行与可链接格式) 是一种为高级语言代码和数据提供的标准二进制表示格式。

常见的 ELF 文件可以分为三类：**可重定位文件**（`.o`）、**共享目标文件**（`.so`）以及**可执行文件**。

ELF 文件在设计上具有**双重特性**，它在编译链接期和运行加载期呈现出两种不同的视图：

- **ELF header**：描述文件的总体结构和元数据（如魔数、体系结构、入口地址等）。
- **链接视图 (Linking View)**：以 **Section（节）** 为单位。提供给链接器 (Linker) 使用的 Section Header Table。链接器将不同目标文件中相同类型的 section 进行解析和合并。
- **执行视图 (Execution View)**：以 **Segment（段）** 为单位。提供给加载器 (Loader / OS Kernel) 使用的 Program Header Table。加载器会将多个权限相似的 section 映射成一个 segment（例如将代码段和只读数据段合并映射为只读且可执行的内存区域），以方便运行时加载。

## 核心文件类型详解

### 1. 可重定位文件 (Relocatable Files)

通常为 `.o` 后缀文件，是源文件编译汇编后的中间产物。
它包含了代码和数据，但其中的地址是未决的（通常从 0 开始计），需要与其他目标文件合并、重定位才能真正运行。

经典的 Section 包括：
- `.text`: 编译后的机器码，代码段
- `.rodata`: 只读数据，如 `printf` 的格式化字符串常量
- `.data`: 已初始化的全局/静态变量
- `.bss`: 未初始化（或初始化为 0）的全局/静态变量（不占实际磁盘空间，只记录大小）
- `.symtab`: 符号表，记录了函数名、全局变量等符号信息
- `.debug`: 调试信息

{{% spoiler "生成可重定位文件演示" %}}
```shell
gcc -c main.c
```
*这会生成 `main.o`。*
{{% /spoiler %}}

### 2. 共享目标文件 (Shared Objects)

通常为 `.so` 后缀文件（Windows 下称为 DLL）。
它是一种特殊的可重定位文件，但主要作用于**运行时或加载时**。编译时通常生成**位置无关代码** (Position Independent Code, PIC)，即内部调用多使用相对地址。

运行一个程序时，操作系统的加载器 (`execve`) 会初始化进程状态机，利用 `mmap` 将进程的虚拟地址映射到对应的 ELF 文件上（初始时只映射不加载，触发缺页中断时才真正读入物理内存）。动态库被映射进内存后，可以被多个不同的进程共享，从而节省物理内存空间。

{{% spoiler "共享目标文件与动态链接演示" %}}
**1. 生成共享目标文件**
```shell
gcc -shared -fPIC -o libfoo.so a.o b.o
```
*或者直接用源文件：`gcc -shared -fPIC -o libfoo.so a.c b.c`。*

**2. 链接动态库生成可执行文件**
```shell
gcc bar.o ./libfoo.so
```
*生成的可执行文件并不包含 `libfoo.so` 中的指令，只含有一些重定位和符号引用信息，留待运行时处理。*

**3. 查看动态链接情况**
```shell
ldd a.out
```
{{% /spoiler %}}

### 3. 可执行文件 (Executable Files)

经过静态或动态链接后，所有符号地址已确定，生成可以被系统直接运行的文件。
可执行文件拥有一个**入口点 (Entry point)**，通常名为 `_start`。这是链接器从标准库加入的一段初始化指令，用于设置进程环境，完成初始化之后才会跳转到我们编写的 `main` 函数。



## 链接原理简述

链接器（Linker，常见如 `ld`）主要将可重定位文件组合在一起，其核心步骤如下：

{{% notice note "Linker 静态链接核心步骤" %}}
1. **符号解析 (Symbol Resolution)**：链接器从左至右扫描命令行输入的重定位文件和静态库（`.a`）。将代码中的每个符号引用与其确切的定义进行绑定（更多细节参见参考文献）。
2. **重定位 (Relocation)**：合并多个目标文件中的同类型 sections，为它们分配运行时的绝对内存地址；随后，修改代码段 and 数据段中对符号的引用，使其指向这些新的物理地址。

{{% spoiler "静态链接演示" %}}
```shell
gcc foo.o bar.o /usr/lib/libc.a /usr/lib/libm.a
```
*手动链接了 C 标准库和数学库的静态版本。*
{{% /spoiler %}}
{{% /notice %}}

{{% notice warning "静态链接的缺点" %}}
静态链接会将静态库中的代码直接拷贝到最终的可执行文件中，这使得最终的 ELF 文件变得非常臃肿，造成磁盘和内存的浪费。
例如：如果系统里有 50 个程序都使用了 `printf` 函数，使用静态链接的话，这 50 个程序的执行文件中都会冗余包含一份 `printf` 的机器指令副本。
{{% /notice %}}

而**动态链接**则解决了这一问题，它将链接过程推迟到加载时甚至是运行时进行，使得像 `libc` 这样的库在内存中只需保留一份。

---

## 参考文献

- [Linkers and Loaders](https://www.linuxjournal.com/article/6463)
