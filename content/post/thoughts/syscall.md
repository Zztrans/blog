---
title: "Syscall"
slug: "syscall"
description: 
date: 2024-02-25T23:22:23+08:00
image: 
math: 
license: 
hidden: false
comments: true
categories: thoughts
tags: [心情, 流水, OS]
draft: false
---

## 前言

读了几篇 syscall 相关的文章，做了一些总结。

用户编写的程序基于用户态库，经历 app -> lib -> syscall -> kernel 的调用链，最终交给 kernel mode 做一些关键的事情。

{{% notice note Note%}}
The end goal of writing a kernel is to get to userspace, or, in other words, going from ring 0 to ring 3.
{{% /notice %}}

## performance

这篇 [文章 ](http://arkanis.de/weblog/2017-01-05-measurements-of-system-call-performance-and-overhead)，作者使用各种不同的 cpu 硬件平台，编程设置了 benchmark 测试了一些 syscall 的性能开销。

如 getpid() (glibc < 2.25, getpid() is no longer cached by glibc starting with 2.25.)

使用 vDSO(virtual Dynamic Shared Object) 相比普通的 syscall instruction 形式会快很多，非常接近普通函数的调用开销。

但评论似乎也有人说是 glibc cacheing 的功劳。根据 `man getpid` 所说确实如此，所以这次实验只能说明 cacheing 带来的加速。

{{% notice tip vDSO%}}
和 vsyscall 类似，都是一种系统调用加速机制。

将部分内核中 syscall 对应的地址空间通过 `动态共享库 (.so)` 直接映射到用户空间。

vDSO 暴露的系统调用不多，进一步介绍可以在 [文章](https://tinylab.org/riscv-syscall-part3-vdso-overview/) 中找到，是平台而不同的。
{{% /notice %}}

`ldd  /bin/bash` 可以看到 ELF 链接的共享库情况，其中就有 vDSO，同时可以发现有 ASLR 机制。

fread() 和 fwrite()会比 read() write() 快 8 倍？从 file stream 中进行 IO 操作非常快。

而 vDSO 对 read()，write()几乎没有提升。

