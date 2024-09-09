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

## unordered_map 

哈希 细节

自定义数据类型, 重载 key 的 hash 函数

load_factor > max_load_factor 则 rehash。

bucket_count : 桶大小，一般是一些素数，类似两倍扩容的素数，比如 5, 13, 29, 59, 127

load_factor = size / bucket_count

max_load_factor 默认是 1

## 并发编程 thread

join : 主线程会阻塞，直到分出来的线程执行完毕

detach : 分离，后台执行，脱离主线程，主线程会继续执行。

同步机制：

mutex

conditional_variable

