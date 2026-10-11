---
title: "Virtualization"
slug: virtualization
date: 2026-06-20T14:31:31+08:00
description: 
image: 
math: true
comments: true
tags: []
categories: 
    - note
---

[虚拟机和容器 2026 南京大学操作系统原理](https://www.bilibili.com/video/BV1uaEB66EAH)  

## 操作系统级仿真(虚拟机)

### shadow page Table

{{% notice note 一种老式历史技术%}}

    1. 额外维护一份页表
       Guest 页表:  GVA → GPA  （Guest OS 维护，VMM 不让 CPU 用）
       影子页表:    GVA → HPA  （VMM 维护，CPU 实际用这个）

    2. 拦截 CR3
       Guest 写 CR3 → VM Exit → VMM 偷偷把 CR3 指向影子页表
       Guest 读 CR3 → VMM 返回 Guest 以为的那个值（骗它）

    3. 同步
       Guest 改自己的页表 → 影子页表过时 → 必须同步更新
       检测方式：把 Guest 页表页标记为只读 → Guest 一写就触发 Page Fault → VMM 介入同步

{{% /notice %}}

VMM = Virtual Machine Monitor

即每次改 guest 页表的时候都会触发 VMM 管理的行为，有很大的性能开销。

### EPT（Extended Page Tables，扩展页表）

{{% notice tip 现代主流技术%}}
  
  EPT 是 Intel 在 CPU 的 MMU 硬件里加的第二级页表，让 CPU 原生支持 GPA→HPA 的翻译，不再需要软件维护影子页表。

    CPU 的 MMU 现在做两级翻译：

      第一级：Guest 页表（Guest OS 维护）
        GVA → GPA
      第二级：EPT（VMM 维护）
        GPA → HPA
      **两级翻译由 MMU 硬件自动完成**，不需要软件介入

  图示：
    ┌──────────────────────────────────────────────┐
    │                  CPU / MMU                    │
    │                                              │
    │  GVA ──→ [Guest 页表] ──→ GPA                │
    │              ↑                ↓               │
    │         Guest CR3        [EPT 页表]           │
    │        (Guest 管理)          ↓               │
    │                            HPA               │
    │                          ↑                   │
    │                     EPTP 寄存器              │
    │                    (VMM 管理)                │
    │                                              │
    │          全部由硬件自动完成                    │
    └──────────────────────────────────────────────┘
    
{{% /notice %}}

代价：Page Walk 变长了。guest OS 里的页表，每一级都又多了一个 GPA->HPA 的页表映射需要查询。

      1. 读 Guest CR3 → 这是个 GPA → 查 EPT（4次访问）→ 得到 HPA
      2. 读 Guest PML4 条目 → GPA → 查 EPT（4次）→ HPA → 读出条目
      3. 读 Guest PDPT 条目 → GPA → 查 EPT（4次）→ HPA → 读出条目
      4. 读 Guest PD 条目   → GPA → 查 EPT（4次）→ HPA → 读出条目
      5. 读 Guest PT 条目   → GPA → 查 EPT（4次）→ HPA → 读出条目

      总计：最多 5 × 4 = 20 次内存访问（一说 24 次，取决于算法）
      对比无虚拟化的 4 次

但实际还好，实际测量下来，EPT 带来的额外开销大约 1~5%，远小于影子页表的 VM Exit 开销。

VMware、Hyper-V、WSL2、 各大云厂商（AWS/Azure/GCP）都使用该技术，现代 CPU 已经全部支持 EPT。

## 应用级仿真(容器)

{{% notice note 真的需要这么重吗%}}
从需求视角出发，虚拟化最终是为了应用。应用视角，看不到别的应用就可以了。
{{% /notice %}}

想象给每个 os 里的数据结构加一维 []，表征 osid，每个进程访问自己的：

比如哪些方面的 osid 呢？
- pid
- user
- mnt
- ipc: 信号量、消息队列、共享内存
- net
- time

**linux namespace** 做到隔离 

{{% notice warning 再进一步%}}
控制资源。 资源调度机制 cgroup
{{% /notice %}}

namespace + cgroup + overlayFS(分层镜像) == docker

## 云时代的虚拟机

k8s：容器编排
- 动态、透明管理的 无状态 的 容器 Pod
- 声明式的访问和路由
