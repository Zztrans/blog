---
title: "记一次服务器重装系统"
slug: 202303
description: 背锅.jpg
date: 2023-03-16T19:20:39+08:00
image: img.jpg
math: true
comments: true
tags: [心情, 流水]
categories: thoughts
lastmod: 
---

## 流水碎碎念

TL; DR: 接锅了
<!-- 
{{% spoiler "TL; DR" %}}

周五晚上服务器挂了个实验就没管，周六早上发现 ssh 登不上，问了一个同学说他也登不上， 遂没管， 反正大概总归会好的， 只是没想到是我修。

之后老板先是由于我之前帮别的同学装过系统， 有制作启动盘的经验， 就叫我帮负责服务器管理的师兄做个启动盘， 我寻思怎么启动盘都不会做， 由于这个锅看起来并不大，就接下了。

后来又 call 我说可能是一个本科生搞坏了， 让我帮师兄打下手。

周一来做了启动盘， 下午老师就让我们修， 说他有很多方案， 修不好就叫他们厂商上门等等。

然后就从一个启动会 kernel panic 的服务器和一个 u 盘开始搞，老师把我拉进了厂商对接的群聊，师兄提供了一个显示器，别的感觉师兄也不太会。

{{% notice note 后记%}}
这完全没给我打下手的机会啊
{{% /notice %}}

厂商那边给的都是抽象的干啥，没命令我第一次接触咋知道咋做。。。

于是求助某运维大师， 刚好他有一篇 [作品](https://note.cubercsl.site/notes/6246dde7/)， 部分内容如有雷同都是我抄的。

情况就是系统烂了， 进不去了， 但里面的数据需要捞。实验代码可都在服务器里没做备份的， 如果扔了可不就真阿凉了。

整体流程就是需要把数据备份一下到一个非系统盘上， 然后重装系统， 再还原回去。

{{% notice tip story%}}
期间运维大师还尝试让我远程给他一个 `shell` 修这个 kernel panic。

详细了解了一下那个本科生的行为大概是往 ubuntu 上装了 yum， 然后用 yum 装东西的时候把一些系统组件搞烂了， `包括systemd在内的一些系统核心组件依赖glibc`。当然他是有 sudo 的， 我也不知道他怎么拿到的。。。。。。

大师搞了一些我看不懂的操作， 备份完重启后一直在 boot splash 界面进不去， 鉴定为好了没完全好， 于是还得重装系统， 之后又配置搞了半天差不多服务器又能正常使用了。
{{% /notice %}}

{{% /spoiler %}} -->

情况就是服务器的系统烂了， 进不去了， 但里面的数据需要捞。 

以下以一个 newbie 视角大致说一下干了什么。

## 备份数据

插入一个制作好的启动盘， F11， ctrl+alt+F2~6 尝试进入一个 `tty`， 先判断一下各种已知设备名分别是啥，挂一下原来盘， 然后捞原 root 的 home 目录下的数据即可:

```bash
lsblk
mkdir /mnt/oldroot /mnt/backup
mount /dev/sda1 /mnt/oldroot
# mkfs.ext4 /dev/sde1 看需不需要格了备份数据盘
mount /dev/sde1 /mnt/backup
mkdir /mnt/backup/home
rsync -aHAXv --progress /mnt/oldroot/home /mnt/backup/home
```



{{% notice note rsync%}}
`rsync` 是一个 nb 的 `cp`， 支持 remote 和 local， 同时已经一致的不会再传， 还带保存 file 的各种 attribute， 包括用户和权限之类的。 

Rsync is widely used for backups and mirroring and as an improved copy command for everyday use。
{{% /notice %}}

还有似乎需要注意最好保证文件系统类型(我这里刚好都是 ext4)一致，且有些文件可能需要权限才能传递，rsync 命令需要在 sudo 下执行。

要捞的可能还有一些原来的配置，比如你可以看看原来的

- 显卡驱动版本 /mnt/oldroot//proc/driver/nvidia/version
- 数据盘挂载位置 /mnt/oldroot/etc/fstab
- 网络配置 /mnt/oldroot/etc/NetworkManager/system-connections 里的东西
- 用户组 /mnt/oldroot/etc/group， /mnt/oldroot/etc/passwd
  
同样也可以备份记录一下， 方便你完全恢复原状。

## 重装系统

下 iso 文件花了比较久，rufus 刻起来倒是很快，分区类型新机器可能选 GPT 多一些，别的都是默认。

重启服务器，启动的时候按 F11， 直接开 install 就完了， 由于听老师说之前就是桌面版， 因而继续用桌面版， 一路上几乎不需要配置， 但由于装的是服务器，还是问了好几个傻逼问题，其实可能和普通机器并无任何区别，这时候原来的烂的系统盘就会被取代。

{{% notice tip naive%}}
我才知道服务器上不一定装的是 server 版的 ubuntu ?
{{% /notice %}}

服务器系统版本用的是 Ubuntu 18.04.6 LTS desktop 的。

## 恢复配置

### 用户

可以考虑按照这个模式写一个脚本， 做好原来 id 和 name 的对应即可。

```bash
groupadd -g gid <groupname>
useradd -s /bin/bash -u <uid> -g <gid> <username>
echo "username:password" | chpasswd
```

推荐一条一条加回去， /etc/gshadow 和 /etc/shadow 可能都是加盐加密过的， 直接复制应该会出问题。

### 网络

网络， ip 在之前备份的时候查看一下， 由于是桌面版大概只需要在 settings 里填一下 ip， 子网掩码和网关， 还有 nameserver， 然后 reboot 即可。

这样就能 ping 出去了。

### 恢复 home 和数据盘

这里要注意一下别像我一样最终嵌套太多 home，可能不太能对应上原来 /home/username 的形式，/mnt/home 可能需要改成 /mnt/home/home/，自己注意一下。

```bash
mount /dev/sde1 /mnt
rsync -aHAXv --progress /mnt/home /home
```

建立原来数据盘的挂载点

```bash
mkdir /data /data1
vim /etc/fstab
# 编辑 挂载信息， UUID 可以通过 blkid 查看
mount -a
```

### 显卡驱动

显卡驱动， 首要任务是能让大(zi)家(ji)跑实验。

首先是版本， 希望和之前尽可能一样(能用你就别动他)。 但我之前没经验没查看这个，也不记得之前的 driver version 了。

很小心的看了不少博客发现有不少坑， 感觉很麻烦。 各种各样的方式和 bug 太多了没个准信， 最后还是看了个日语的 [blog](https://hirooka。pro/nvidia-driver-ubuntu-20-04/)，大概直接走 apt install 了。

```bash
ubuntu-drivers devices
sudo ubuntu-drivers install # 会按上面一个命令显示的recommend的版本给你装一个
sudo reboot
```

然后 nvidia-smi 就有了。

目前还没碰到别的问题， 碰到再修。

<!-- ### 服务器配置

不想调模型， 无聊用 root 看了下服务器配置。。。

> /proc/cpuinfo
>
> model name : Intel(R) Xeon(R) Silver 4210R CPU @ 2.40GHz
>
> cat /proc/cpuinfo | grep "physical id" |sort |uniq
>
> 有 2 个物理 cpu， cpu cores 是 10， 每个 10 核， 有超线程， 一共呈现出 40 个 processor

/proc/meminfo

MemTotal 大概是 125G。

4 个 3070， 显存 8G(好小啊)

感觉配置也非常一般啊。 -->

以上就是我干过的事情。。。。。。好像总共也没几条命令。。。。。。

挺简单的是吧.jpg