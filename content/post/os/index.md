---
title: "OS 理念整理"
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

大名鼎鼎的 ELF 格式，可执行可链接文件，一种的代码二进制表示。

包含以下几类， 可重定位文件，共享库文件，可执行文件，都可以称作 ELF。

主要包括 

section header, program header

### 可重定位文件

常见 .o 后缀

```shell
gcc -c main.c
```

作用于编译期，可以与源文件和其他文件一起重新编译 链接(linker)。

没有确定的地址

链接 -> section

## 共享库文件

常见 .so 后缀

可用于运行时加载 (loader) 的 动态库、动态链接库文件

```shell
gcc -shared -fPIC -o liba.so a.c
```

-fPIC 表示生成位置无关的代码，即相  对地址

加载 -> segment 

一个 segment 内包含很多的 section，一段一段 被加载进 地址空间

## 可执行文件

不指定，默认的

有 entry 入口，通常是 __start

