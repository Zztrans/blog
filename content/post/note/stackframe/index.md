---
title: "Stackframe"
slug: stackframe
date: 2026-06-16T00:14:36+08:00
description: 
image: 
math: true
comments: true
tags: [os, compile]
categories: 
    - note
---

## 栈帧

以下基于 x64 汇编进行展开

{{% notice tip 常见寄存器语义%}}
ip：指令指针(Instruction Pointer)

bp：栈基指针(Base Pointer)

sp：栈顶指针(Stack Pointer)

在 64 位架构下，上述寄存器通常带有 r 前缀（代表 register）
{{% /notice %}}


一条函数调用指令 call 所做的事情：

- 将 call 指令紧接着的下一条指令(当前函数)的地址（即返回地址）压入栈中。

- 将目标函数的首地址赋给 rip，从而改变执行流实现跳转。

{{% spoiler 典型x64函数汇编结构 %}}
    push rbp
    mov rbp rsp 
    ...
    pop rbp
    ret     # ①rip = [rsp] ②rsp = rsp + 8 
{{% /spoiler %}}

简而言之，上述汇编在做的事情就是在把之前的栈基信息给记下来，然后去构筑当前栈帧，当前函数结束后回到之前的信息。

{{% notice info 我自己疑惑的点%}}
基本上大部分通用寄存器的读写语义都会显式写出来，但唯独 rsp/rip 的语义比较特殊。

RSP 仍可被显式操作，RIP 则几乎完全只能被控制流指令隐式修改。

凡是分配或释放栈空间，或者隐式跨越函数边界时，都会使得 **sp** 隐式移动 (push/pop, call/ret, enter/leave,int/syscall)

而 rip 永远指向下一条要跑的指令的地址。(jmp， call/ret， int/syscall)

这些语义是嵌入在具体的指令中的。
{{% /notice %}}

{{% notice note 进阶%}}

为什么有时候退栈没有 pop rbp，只有 一条 leave 指令？

无局部变量的情况：即将退栈的时刻，栈顶 RSP 和栈底 RBP 是重合的，无需多余操作。

有局部变量的情况：二者之间存在 gap 存储局部变量，因此需 ① mov rsp, rbp  ② pop rbp

leave = ① + ②

{{% /notice %}}

## 编译器前后端之分

编译器最终目的：高级语言 -> 机器码

假设 N 种高级语言，M 种目标平台的机器码。

naive 的实现就是 $N \times M$ 种都去做适配，每新增一种平台或机器码都要做一堆适配。

经典的设计就是 提取一种中间表示，IR(intermediate representation)。 前端专注 高级语言到 IR，后端专注 IR 到目标平台机器码的优化。

**适配器模式**

举例：
编译器经典三段式架构
编译器的核心设计是按“机器相关性”进行解耦的：

- 前端（Frontend / 机器无关）：负责“理解”语言。执行词法、语法、语义分析，将源语言转化为统一的中间表示（IR）。它只关心代码的业务逻辑，不关心最终跑在 x86 还是 ARM 上。

- 中端（Optimizer / 机器无关）：负责“通用优化”。在 IR 层面进行与硬件无关的逻辑简化，比如常量折叠、死代码消除。

- 后端（Backend / 机器相关）：负责“落地”硬件。将 IR 翻译为特定微架构的汇编/机器码，并充分榨取硬件性能。

编译器的前端在业界是一个比较成熟的领域，可能不会有特别的多的变化。反而大学书本和课程实验会对这一块儿教授和实验的比较多。

后端有很多工作，比如 指令选择与调度、寄存器分配、代码布局优化。

## 结束语

编译器怎么选择，主流 gcc 和 llvm

    GCC 架构（一体式）：
      源码 → 前端(C/C++/Fortran/...) → GIMPLE IR → RTL IR → 机器码
             └── 语言和后端紧耦合，中间表示多层 ──┘

    LLVM 架构（模块化）：
      源码 → Clang前端 → LLVM IR → 优化Pass → 机器码
             └── 前端/优化/后端 完全解耦 ──┘
                  ↑
             任何语言都可以生成 LLVM IR（Rust, Swift, Zig...）

{{% notice tip llvm想解决gcc的什么问题%}}
1、架构耦合：无法当"库"来用 -> 于是LLVM做了模块化，LLVM 是一组可独立使用的库：

      libclang       — 解析 C/C++，可嵌入 IDE
      libLLVMCore    — 操作 IR
      libLLVMPasses  — 跑优化
      libLLVMCodeGen — 生成机器码
      libLTO         — 链接时优化
      MCJIT/ORC      — 运行时 JIT 编译
2、中间表示（IR）：GCC 的 IR 太多太乱  ->  LLVM 只有一种 IR

    GCC 的编译流水线：

      源码 → AST → GENERIC → GIMPLE → SSA-GIMPLE → RTL → 机器码
                    ↑          ↑                     ↑
                高层 IR      中层 IR               低层 IR

      三种 IR 之间转换时信息丢失，
      每种 IR 有各自的优化 pass，
      代码重复，维护困难。
3、可扩展性：加一个优化 Pass 有多难？GCC 的问题：

    想给 GCC 加一个自定义优化：
    1. 理解 GIMPLE 或 RTL 的内部表示（文档很少）
    2. 理解 pass manager 的注册机制
    3. 小心不要破坏其他 pass 的假设
    4. 编译整个 GCC 来测试（很慢）
    5. GPL 要求你的 pass 也必须 GPL
    → 门槛极高，几乎只有 GCC 核心开发者能做

{{% /notice %}}

llvm 是一个扩展支持、开源社区化的编译器，

gcc 现在看起来有一些历史包袱，但地位依然难以撼动。

但在性能上其实还是得看具体场景，跑过才知道。