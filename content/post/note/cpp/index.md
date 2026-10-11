---
title: "cpp"
slug: cpp
date: 2024-04-22T23:44:23+08:00
image: 
math: true
comments: true
tags: [cpp]
categories: note
lastmod: 
draft: true
---

# cpp

一些面试问到的点，后面深入了解了下。

## 一些语法

### noexcept

异常，维护异常信息需要额外生成的 try-catch 等众多指令，和性能存在矛盾 trader-off。

### 可变参数模板

typename... _Args  (可变参数模板)

### 完美转发

_Args&&... __args  与  std::forward  (完美转发)

举例 

obj(std::forward<_Args>(__args)...);


在 C++ 中，传递参数如果用值传递会产生拷贝，用引用传递又区分左值（普通变量）和右值（临时对象，比如  std::move过来的）。
  •  &&  在这里叫做万能引用。无论你传进来的是普通变量还是临时变量，它都能接住；配合内部的  std::forward
  ，它能保证：传入的参数如果是右值，传给构造函数时依然是右值，绝不多产生哪怕一次无用的内存拷贝。
  

### 右值引用


## stl

### allocator

{{% notice note 为什么需要%}}
一个对象初始化的时候，其实同时涉及 内存分配，以及对象构建。解耦二者，专门分配器去做内存申请这一块儿。
{{% /notice %}}

本质做啥呢？

封装一层 申请内存(allocate)、构造对象(construct)、销毁对象(destroy)、归还内存(deallocate)的接口。

大白话：
new -> 在new出来的内存上手动调用构造 

### 初始化一个 vector发生了什么？

构建一个临时 allocator 对象(空)，传给 vector，基于 allocator 来完成内存申请和对象构造。

### unordered_map 


自定义数据类型, 重载 key 的 hash 函数

load_factor > max_load_factor 则 rehash。

bucket_count : 桶大小，一般是一些素数，类似两倍扩容的素数，比如 5, 13, 29, 59, 127

load_factor = size / bucket_count

max_load_factor 默认是 1

## 并发编程 thread

join: 主线程会阻塞，直到分出来的线程执行完毕

detach: 分离，后台执行，脱离主线程，主线程会继续执行。

同步机制：
- mutex:
    如何实现：

- conditional_variable
    如何实现：

{{% notice warning 更深入一些%}}
大家都知道thread模型是什么，简单来说是一段代码、一段执行流，能被 OS 线程调度。

那 thread 是如何从一个函数构造出来的，背后发生了什么呢？

1、参数解包
2、类型擦除问题：
解决C++自由灵活的模板泛型语法  和 C语言死板api之间冲突，因为底层C库里有 void*，无法知道怎么转化。
设计 基类 _State，把编译期的模板多态，转化为了运行期的虚函数多态。

3、底层调用 pthread_create，完成线程创建

{{% /notice %}}


## 类设计

在 C++ 类设计中：

  • 用值 ( T ) 或 智能指针 ( unique_ptr<T> )：代表“我拥有它，我负责它的生老病死”。（绝大多数类成员应该用这种）
  • 用裸指针 ( T* )：代表“它可以为空，也可以在运行中随时换指向另一个目标”。（如  FILE* ）
  • 用引用 ( T&)：代表“我必须依赖外部传入一个实体，它绝对不能为空，我也不能换绑，而且我不负责销毁它”。通常只用于一些依赖注入的场景或者观察者模式。

访问控制
public
protected
private
