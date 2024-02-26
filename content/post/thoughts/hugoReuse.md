---
title: "restart blog？("
slug: "HugoReuse"
description: 
date: 2024-02-25T21:11:12+08:00
image: 
math: true
comments: true
tags: [随笔]
categories: thoughts
lastmod: 
draft: false
---

## 前言

在上学期自己配置了主机，第一次拥有自己 diy 的丝滑主机。

由于价格的透明，主机 diy 过就知道其实很好自己装一套高性价比的，不至于成为 "整机烈士"？

这也导致原来的笔记本一直闲置，几乎没有使用场景。

位于笔记本上 blog 的源文件也就一直没取出。而且我居然没用 git 做版本管理和做云存储。

于是手动重新迁移了下原来的 file 到新主机，并设置了博客源文件的 git remote repo。

## WSL 配置 hugo

在新主机的 WSL 上重新配置了环境，遇到了一些新坑。

### detect 不到 file change

大概是我想把文件留在在原来 win 的 filesystem 上，但使用 wsl 来开发和部署 hugo 。即目录是 /mnt/c/xxx/blog 这样。

这样修改文件并不能被 wsl 中的 hugo 检测到，也就没有 hugo 热加载的特性。

根据 [论坛](https://discourse.gohugo.io/t/a-cautionary-tale-mixing-windows-and-wsl-windows-subsystem-for-linux/17896/11) 的见解

{{% notice note Note%}}

Filesystem change/watch events (what hugo serve looks for with fsnotify) are low-level and OS-specific, and it seems WSL does not yet provide the same kind of environment/functionality for it’s Windows files into the Linux kernel (yet).

{{% /notice %}}

hugo 用了 [fsnotify](https://github.com/fsnotify/fsnotify)。

猜想 fsnotify 还没有跨平台的支持？因此不能跨文件系统支持？

解决方法就是将文件真的放在 wsl 里。

### 字符乱码

在我的原来的 win 系统中的 文件 path 文件名中存在中文，直接复制迁移到 wsl 上乱码。

原来是 windows 默认使用 UTF-16 编码来存储文件名，linux 当然是 UTF-8 了，中文字符可能在上面会出现差异。

## 结束语

再把 hg23 的 wp 放上来，之后图片估计都懒得找了。

在 vscode 中做了一些 hugo shortcode 的 snippet 定义便利写作，还有装 markdown 中英文间的 padding 和 format 之类的扩展，似乎就重启完了？(