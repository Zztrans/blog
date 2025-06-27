---
title: "ELF simple concept"
slug: "OSconcept"
description: 
date: 2024-09-08T23:44:23+08:00
image: 
math: true
comments: true
tags: [os]
categories: note
lastmod: 
---

## ELF

ELF 格式，可执行可链接文件，一种的代码二进制表示。

分类大概包含以下几类， 可重定位文件，共享库文件，可执行文件，都可以称作 ELF。

文件内容上主要包括下面几部分：

- ELF header

- section header table -> 链接的概念 section，为链接器提供信息，解析确定找到对应的符号

- program header table -> 加载的概念 segment，告诉加载器或者 OS kernel 运行时怎么加载

## 可重定位文件

常见 .o 后缀，可以认为是原生 naive 版？

生成方式：
```shell
gcc -c main.c
```

作用于编译期，可以与源文件和其他文件一起重新编译 链接(linker: 常见 ld)。

链接 -> section

链接详细做了什么：

1. 重定位，把多个目标文件，同类 section 合并。
2. 多个目标文件，符号解析，能找到对应的代码是哪个的。

链接完也能生成一个可执行文件。但是基于的是编译期，各种 object files 的重新整合。

静态链接方式：
```shell
gcc foo.o bar.o /usr/lib/libc.a /usr/lib/libm.a
```
这里链接了两个静态库

{{% notice note Linker 静态链接%}}

算法上做了什么？

首先符号解析

During the process of symbol resolution using static libraries, linker scans the relocatable object files and archives from left to right as input on the command line. 更多细节参见参考文献

其次，合并 同类型 sections，分配运行时地址

最后，重新分配 section 内符号解析的对应地址。

{{% /notice %}}


经典的 section

.text: 机器码，代码段
.rodata: 只读数据，如 print 的串
.data: 已初始化的全局变量
.bss: 未初始化的
.symtab: 函数名符号，全局变量符号
.debug: 调试信息


{{% notice warning 静态链接缺点%}}
使得 ELF 臃肿，对内存，对 disk 存储都浪费。

比如 50 个程序都用 printf，运行时内存上，和存储都冗余很多。   

{{% /notice %}}

## 共享库文件

常见 .so 后缀，win 下叫 DLL

一种特殊的可重定位文件？ 作用于加载时或者说运行时。

运行时加载 (loader: execve(初始化进程的状态机) + mmap 映射进程虚拟地址到文件上，只映射不加载，读写时才缺页中断去真正处理) 的 动态库、动态链接库文件

加载 -> segment 

一个 segment 内包含很多的 section，一段一段 被加载进 地址空间

生成：
```shell
gcc -shared -fPIC -o libfoo.so a.o b.o(a.c 源文件也可以)
```

-fPIC 表示生成位置无关的代码，即内部使用的都是相对地址

上述命令表示 让 linker 生成一个 libfoo.so，由 a.o b.o 组成

使用：

```shell
gcc bar.o ./libfoo.so
```
假设 bar.o 依赖 a.o， b.o，可以如上操作，让 动态链接器 linker 创建一个 a.out，a.out 本身并不含 a.o，b.o，只含有一些重定位和符号引用信息，能让你在运行时找到。

可以使用 `ldd` 查看动态链接情况

## 可执行文件

有 entry 入口，通常是 __start，是一个初始的指令地址，是链接器从标准库帮你统一处理加的一段初始化函数，之后才会跳到编写的 main。

实现将从 disk 的可执行文件，到进内存中的进程的状态机。

## 参考文献

[Linkers and Loaders](https://www.linuxjournal.com/article/6463)
