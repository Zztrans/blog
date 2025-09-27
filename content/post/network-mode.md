---
title: "网络模式"
slug: "Network-Mode"
description: 
date: 2025-09-27T18:04:24+08:00
image: 
math: true
comments: true
tags: [虚拟化, 计算机网络]
categories: note
lastmod: 
draft: 
---

## 前言

之前是有 gemini pro 的学生适用，网页平时用用很舒爽。但是毕业了似乎出了变故被回收了。

但是不想每月 20$ 的送钱。

据说 gemini cli 免费，于是想在我的 WSL2 上配一下。



装完 gemini 会遇到登录 auth 失败的情况，似乎是 gemini 这里在 WSL 起了个 服务，有个 callback URL要访问。

本来我的 WSL2 使用的是 NAT 模式，有开一个 localhostForwarding 的选项。

{{% notice note 据gemini-flash说%}}
当 localhostForwarding 设置为 true 时，它启动了 Windows 和 WSL 之间的透明端口转发机制，主要解决以下两个方向的访问问题：

1. Windows 访问 WSL (最常用)

问题回顾： 在默认的 NAT 模式下，WSL 内部的服务运行在 172.x.x.x 地址上，Windows 访问 localhost:<PORT> 找不到它。

启用后的效果： 如果你在 WSL 中启动了一个 Web 服务器（例如在 http://localhost:3000），你的 Windows 浏览器可以直接访问 http://localhost:3000 来打开这个服务。
  
机制： Windows 会自动侦测 WSL 内部正在监听的端口，并在 Windows 侧创建临时的转发规则，将 localhost 的流量导向 WSL 的真实 IP。

2. WSL 访问 Windows

问题回顾： WSL 内部的 localhost 默认指向 Linux 虚拟机自己，无法访问 Windows 主机上的服务（如代理服务器、数据库）。

启用后的效果： WSL 内部的进程也可以通过 localhost (或 127.0.0.1) 来访问在 Windows 主机上运行的服务。

机制： 这个配置确保了流量能够从 WSL 发送到 Windows 主机，简化了跨环境通信。

{{% /notice %}}

但不知道为啥 NAT localhostForwarding下，没法让本机访问到 WSL2，网页点了 auth 卡住。怀疑的一个点是我本机的代理？

于是改了下 WSL2 的配置，升级了下 win11 下新提供的镜像模式，然后就直接行了。

稍微调查总结一下这些虚拟机网络模式的差别。

## 桥接模式

就是局域网中的一台独立的主机，需要手动配置IP地址、子网，与宿主机同一网段，有虚拟网桥连接。

## NAT 模式

本质是个虚拟机，有自己的虚拟网卡，有自己的内网 ip，通过把宿主机当代理网关出口来做。

即 WSL 是内网，强依赖主机的功能。

## 镜像模式

{{% notice info 官方说法%}}
Windows 上的网络接口“镜像”到 Linux。
- IPv6支持
- 在Linux中透过`127.0.0.1`访问Windows服务
- 通过局域网直接连接WSL
- 对虚拟专用网络更好的兼容性
- 多播支持
{{% /notice %}}

看起来就是使用同一套网络配置，网卡 ip 网关之类的。

实际访问谁都是相互的，共用一套 localhost。

dnsTunneling=true

autoProxy=true

都开了会更丝滑吗？还要实验

