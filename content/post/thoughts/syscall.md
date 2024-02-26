---
title: "Syscall"
description: 
date: 2024-02-25T23:22:23+08:00
image: 
math: 
license: 
hidden: false
comments: true
tags: [OS]
draft: true
---

读了几篇 syscall 相关的文章，做了一些总结。

用户编写的程序使用到的 fun 基于用户态库，经历 app -> lib -> syscall -> kernel 的调用链，最终交给 kernel mode 做一些关键的事情。

## performance

这篇 [文章](http://arkanis.de/weblog/2017-01-05-measurements-of-system-call-performance-and-overhead)，作者使用各种不同的 cpu 硬件平台，编程设置了 benchmark 测试了一些 syscall 的性能开销。

---

如 getpid() (glibc < 2.25, getpid() is no longer cached by glibc starting with 2.25.)

使用 vDSO(virtual Dynamic Shared Object) 相比普通的 syscall instruction 形式会快很多，非常接近普通函数的调用开销。

但评论中似乎也有人说是 glibc cacheing，查看 `man getpid` 之后发现 `getpid` 是会 cache，所以此处的性能测试其实是说明 cache 带来的优势。

{{% notice tip vDSO%}}
和 vsyscall 类似，都是一种系统调用加速机制。

内核将部分内核中 syscall 对应的地址空间通过 `动态共享库 (.so)` 映射到用户空间。

vDSO 暴露的系统调用不多，进一步介绍可以在 [文章](https://tinylab.org/riscv-syscall-part3-vdso-overview/) 中找到，是因系统平台而不同的。
{{% /notice %}}

`ldd  /bin/bash` 可以看到 ELF 链接的共享库情况，其中就有 vDSO，同时可以发现有 ASLR 机制。

---

fread() 和 fwrite()会比 read() write() 快 8 倍？从 file stream 中进行 IO 操作非常快。

而 vDSO 对 read()，write()几乎没有提升。
