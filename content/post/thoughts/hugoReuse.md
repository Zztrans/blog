---
title: "restart blog？"
slug: "HugoReuse"
description: 
date: 2024-02-25T21:11:12+08:00
image: 
math: true
comments: true
tags: [心情]
categories: thoughts
lastmod: 
---

## 前言

研二上学期自己配置了主机，第一次拥有自己 diy 的丝滑主机。由于价格的透明，主机 diy 过就知道其实很好自己装一套，不至于成为 "整机烈士"？

原来的笔记本一直闲置，几乎没有使用场景，导致位于笔记本上的 blog 源文件一直搁置。而且我居然没用 git 做版本管理和做云存储。

物理上重新迁移了下原来的 repo 。设置了博客源文件的 git remote repo。

## WSL 配置 hugo

在新主机的 WSL 上重新配置了环境，遇到了一些新坑。

### detect 不到 file change

大概是我想在原来 win 的 filesystem 上启动 wsl，即目录是/mnt/c/xxx/blog 这样，在 wsl 中



### 字符乱码

在我的原来的 win 系统中的 文件 path 文件名中存在中文，直接复制迁移到 wsl 上乱码。

原来是 windows 默认使用 UTF-16 编码来存储文件名，linux 当然是 UTF-8 了，中文字符可能在上面会出现差异。



