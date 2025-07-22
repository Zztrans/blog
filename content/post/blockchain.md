---
title: "区块链"
slug: "Blockchain"
description: 
date: 2025-07-15T09:51:29+08:00
image: 
math: true
comments: true
tags: [区块链,BTC,ETH]
categories: note
lastmod: 
draft: 
---

## 前言

从 [北京大学肖臻老师《区块链技术与应用》公开课](https://bilibili.com/video/BV1Vt411X7JF) 学习一些区块链 basic 的知识。

以下知识基于 18 年的课，部分参数可能经协议修改。

## BTC 

是一套分布式的以账本为核心的交易 (transaction, tx) 记账协议。

~~全世界最慢的世界库？~~

一个算力网络

其激励机制包括 出单个区块的奖励 (初值50BTC，每210,000个区块减半，平均 10 分钟出一个，约4年) 和手续费，保证一共 2100 W 个比特币。

$$
50 \times 210,000 \times (1 + \frac{1}{2}+ \frac{1}{4} + ...) = 50 \times 210,000  \times 2 = 21,000,000
$$

开户 -> 有一对本地的私钥公钥对，有一个好的随机元即可。

公钥取哈希得到地址，从私钥可以推导公钥。

### 数据结构

一个区块数据结构包含 header 和 body。

body 指具体的交易记录，形成一棵哈希树 (Merkel tree)，转账记录需要用交易人的私钥签名，

header 包含如 prev_hash，version，nonce(可调整的随机数)，Merkel tree root hash，nBits，version 等控制信息。

形成区块链 (链表) 的数据结构，基于哈希形成完整性校验机制。哈希性质：

- collision resistance

- hiding

- puzzle friendly

### 网络

网络层基于 P2P overlay network 对等传播。peer 随机选取。

传播主要采用 flooding 泛洪(收到就转发给所有已知邻居)，带宽消耗巨大。

simple, robust, but not efficient.

一个区块数据不超过 1M。

全节点(full nodes)，UTXO：内存维护 unspent BTC。

轻节点(light nodes)，只记录 header，能记录部分转账，向全节点发起验证。也叫做 简单支付验证 (Simple Payment Verification, SPV)

### 挖矿难度

设置挖矿难度参数 (nBits) 使得整个系统平均约 10 分钟出一个区块。这个难度会类似时序平均动态调整，即算力更强大的今天，这个难度也会更大。

哈希用的用的 SHA-256，挖矿哈希函数大约如下：

$$
H(x | nonce | Merkel\ tree\ root | ...) \leq target
$$

比如以前 target 可能是 00000xxxxxxx(256-bits)，现在可能是 0000000000000000000000xxxx(256-bits)。

有数学上的保证，挖矿是 memoryless 的，只和算力本身成正比。

诚实节点应只承认最长合法链，只从最长合法链往后扩展。

{{% notice warning Warning%}}
区块链安全的保证是大部分节点是诚实的，如果不是，恶意节点就可以共谋做很多 attack。

如 selfish attack，forking attack 分叉攻击。

{{% /notice %}}

#### 安全性

{{% notice note Note%}}
BTC 安全性保证在哪？
{{% /notice %}}

1. 密码学上的保证。没有你的私钥，无法伪造你的签名(哈希得到摘要，再用私钥加密摘要得到签名)，没法验证(公钥解密签名，计算原文得到摘要验证完整性)是你。 (这里如果不诚实的节点，不遵循协议验证签名也是有威胁的，所以前提需要网络中大部分节点是诚实的)

2. 共识机制。

### 挖矿

挖矿芯片 CPU -> GPU -> ASIC 专用芯片。

矿池 pool manager，有一套组织激励机制，组织一堆 miner 算力挖矿，让矿工通过降低阈值的 share 证明工作量，让矿工收入稳定一点。

但大型算力矿池组织能威胁 BTC 的安全性，如上面的 forking attack， boycott (抵制攻击，不让某人交易记录上链) attack。

比特币脚本：一系列编写好的验证机制。

### 分叉

state fork，状态上的，上面所说的攻击，或者自然出现的 竞态 fork

---

protocol fork，协议上的，这部分主要关于 软件协议更新

- hard fork

如软件升级分歧 (旧的不认可新的，新的认可旧的)，有人希望增加 block size limit。

现在区块 1M ，一个交易大约 256B 的数据，约 4000个块，10分钟 4000 个交易，才 7 tx/sec，吞吐量较低。

假设 1M -> 4M，并取得大部分算力认可，就会出现真的不可抹去的分叉。

分叉就分家了，分币了！不同共识，可能会拆成多个币，多个链。

- soft fork

假如 1M -> 0.5M，(新的不认可旧的，旧的认可新的)并取得大部分算力认可，会获得临时的小分叉，旧节点挖出来的逐渐没用。

实际比如， coinbase 域， 一部分可以作为 extra nonce 增加挖矿空间。有人提议，将 UTXO 哈希写入这个域后面，验证 UTXO 内容。

### 问答

1. 转账人不在线怎么办？没关系
2. 给陌生公钥转账？可以
3. 私钥丢失？没救了
4. 交易所实际保管了你的私钥，很不安全
5. 私钥泄露，出现可疑交易？应该快点转走
6. 转账地址写错？没救了
7. 偷 nonce？ 不行，有个 coinbase tx 会写矿工收款地址，得写你自己的，偷来没用。
8. 交易费给谁？事先不需要知道

匿名性？

谁都可以查账本，某种意义上不如银行。

人为的每次交易换一个账户？

资金转入转出，与真实世界产生联系。其实是没那么匿名的。

### 思考

1. 哈希指针？实际只有哈希，指针是一个本地内存，分布式没有意义。实际上维护了一个 levelDB，k-v，哈希查对应的块。
2. 区块恋？指私钥切成几分。容易丢失，且密钥安全性大降低。 应该使用多重签名的方式？
3. 分布式共识？比特币并没有达到真正意义下的共识，共识状态可能回滚。
4. 比特币稀缺性？早期高价吸引矿工。总量定死，不适合做货币。
5. 量子计算？不太用担心

## ETH

区块链 2.0？

出块时间 15 s，增加 throughput 吞吐量。

设计 `memory hard` mining puzzle 不想让 矿机成为主流 ， ASIC resistance。

智能合约 smart contract，去中心化的合同？能用代码表示的。

{{% notice note Note%}}
去中心化好在哪里？

应用场景主要在跨国类。司法法律手段较难保证，写入区块链技术手段来保证。
{{% /notice %}}

### 账户

ETH 基于账户的模式，能够轻松防御 BTC 面对最大难题 double spending attack (余额扣了)，花两次攻击，花钱的人不诚实。

但面临 replay attack，重放攻击，收款的人不诚实。

为了防御在交易内容上会额外写上 nonce，代表是发布者的第几次交易。供节点验证检查。

- 外部账户，externally owned account，拥有 balance、none。

- 合约账户，smart contract account，除了上述 域 之外，还有 code 和 storage。不能主动发起交易。

基于 account 的模式，合约的各方，希望账户更稳定。而不是像 BTC 一样变动较匿名。

### 数据结构

#### 状态树

账户状态

addr -> state

addr 为 160 bits，40 个 16进制数。

基本字典树 trie ，40 层，17 个分支，16进制集合外多一个标识结束符。

地址唯一，无视插入顺序，更新局部性较好。

实际使用 **Patricia tree**，压缩前缀树，不分叉的节点缩一下。

{{% notice tip 什么情况下效果最好%}}

key 分布稀疏，哈希后的地址 $2^{160}$ 空间，和已有账户相比确实非常稀疏
{{% /notice %}}

MPT： **Merkle Patricia tree**，普通指针，换成哈希指针。

功能：

1. 证明完整性
2. 验证你有多少钱， merkle proof
3. 证明某个账户存不存在这棵树里

Modified MPT 本质差不太多。

一个 block 的交易只改一部分账户，于是就是 可持久化 modified MPT。（笑死

{{% notice info 为啥不直接改呢而是可持久化%}}
1. 15s 就生成新区块，分叉频繁，可持久化，方便 undo rollback。

2. 以太坊中 状态复杂，智能合约图灵完备(任何有限的逻辑都能表示出来)，能干的事情很多，要想保证回复之前状态，必须记录。
{{% /notice %}}

状态树： (key, value) key 是账户地址，state 对应的 value 则是序列化之后再存。

#### 交易树和收据树

同样 MPT 结构。

状态树在多个区块是共享的。

交易树和收据树是新区块独立拥有的。

收据树：每笔交易的事件日志，创造出来的 树结构。

布隆过滤器 bloom filter：大集合内元素分别做哈希摘要，对 如 128bit 的向量，设置某位 1 的操作。

特性：可能 false positive，误报 (说在，但是哈希冲突的原因，其实不在)，但不会 true negative 漏报。

有什么用？

区块头，有一个总的 bloom filter ，对每个交易回执 (Receipt) 内部小型的布隆过滤器 取并集，可以高效地过滤和查询事件日志。

transaction-driven state machine

### ghost 协议

mining centralization，centralization bias

15s 出一个，导致大型矿池优势更明显，如何减少这些临时性分叉？

新概念，叔叔区块，可以被最长合法链新出块包含进来，也得到一定奖励， uncle reward。 

最多含两个，包含别人能得到 1/32 的奖励。

隔代逐渐减少，从 7/8 的奖励一直到 2/8 的 出块奖励，至多7代，合法的叔叔只有 6 个，鼓励尽早合并。

gas fee 相当于 BTC 的手续费。

出块奖励没有定期减半的说法。

### 挖矿算法

设计目标，让这个问题更不利于矿机，希望普通用户的机器也能参与进来，更安全。

`memory hard` mining puzzle

让挖矿需要内存，设置一个任务， difficult to solve, but easy to verify

ethash 算法：

小 cache (如 16M，包括轻节点都存)， 大 datasets (如 1G，只有挖矿节点才存)

通过逐个哈希的算法，从一个 seed，生成 小 cache。

通过算法 伪随机的 从 小 cache 生成 大的 datasets，找位置，求哈希，生成DAG？ 小 cache 可以直接算 大 dataset 中的值。

挖矿： header nonce 为起点，在大数据集内直接取 按位置 哈希若干次得到 mix，判断是不是 <= target

验证：header nonce 为起点，从 cache 中重新算 dataset 中的元素，check值。验证也需要约 $128 \times 256$ 的计算量？

pre-mining

pre-sale

创世纪 (genesis) 创立者预先设置和卖了一些 ETH。

{{% notice info Info%}}
有观点认为，让普通机器参与进来反而不安全？因为攻击者成本降低了，不如 asic 专用芯片的机器门槛成本高。
{{% /notice %}}

### 难度调整

根据父节点叔叔区块、相邻区域时间戳有一套复杂的调整公式。

难度炸弹 epsilon： 挖矿指数增长难度。

以太坊 希望从 工作量证明 转向 权益证明 PoS (Proof of stake)，不依赖挖矿出矿来取得共识。

### 权益证明

virtual mining？不拼算力，因为算力其根源也是外部世界的财力。

所以新出的币很容易被做局攻击。

干脆直接 比拼 区块链内的 财力，股份制？

机制：Casper the Friendly Finality Gadget (FFG)

引入 validator 验证者，交保证金，推动系统达成共识。

每 若干区块 如 50 个， 称作 epoch，两阶段投票，prepare message 和 commit message，每轮都要 2/3 以上 validator 通过才算通过。

履行职责得到奖励， 不良行为受到处罚。

### 智能合约

solidity

被调用的地方写 合约地址，TX DATA 写调用的函数地址

一个合约可以直接调用另一个合约中的函数， 或者使用 .call(对抗异常更好) .delegatecall(仍在当前上下文)

payable：接收外部交易转账的函数

fallback() 函数，默认的，如果调用了不存在的函数，错的函数，或者没写的情况

智能合约的创建：代码写完，编译成字节码，给 0x0 地址转账，支付汽油费，代码 放在 data 域里，运行在 EVM 上

发起交易的人支付，不同指令消耗汽油费不一样。读便宜，写贵。

gas 多了退，少了回滚不退。

错误处理，assert() require() revert()

嵌套调用是否会导致连锁回滚？ 取决于调用方式

block header 中， gasLimit：该区块可以消耗汽油的上限；gasUsed：区块用的总 gas。

{{% notice note Note%}}
智能合约执行过程中，状态修改都是 先对本地的，只有 区块发布出去，才会传播形成共识。
{{% /notice %}}

所以需要要先执行合约，确定 block header 中 gasUsed，再挖矿。

但 ETH 没有这方面的补偿机制？ 对算力低的矿工，需要先执行合约。除了挖到矿的矿工，别的都没有汽油费。

失败的交易发布吗？也发布，因为要扣汽油费，要形成共识。 Receipt.Status 表明交易执行状态。

solidity 不支持多线程，不希望引人不确定性。 ETH 合约不能产生真正意义上的随机数。

Code is Law. 写出来，被执行了，烂了就是烂了。

通过 addr.send()， addr.transfer()， addr.call.value()() 三种方式付钱都会触发 addr 的 fallback 函数。

转正前先清零， 重入攻击，可以递归调用。

### The DAO

Decentralized Autonomous Organization

一个投资基金计划，ETH 换内部代币，投票决定投资。一个智能合约应用。

但因为上面 重入攻击 代码的 bug，导致盗币时间，被 黑客转走钱，too big to fail。

社区想补救措施，硬分叉，强制 THEDAO 所有账户转入新合约。

{{% notice tip Tip%}}
为什么是所有？而不是仅黑客

因为是合约本身有 bug，不能只冻黑客，谁都可以成为黑客。
{{% /notice %}}

导致 ETH 分裂， 旧链 保守派 成为 ETC。

### 反思

Is smart contract really smart?

- Smart contract is anything but smart.

- Irrevocability is a double edged sword.

- Nothing is irrevocability. 宪法都可以改，区块链也可以改。

- Is solidity the right program language? 自然语言怎么解决的？如现实中的合同条款？也发明新语言吗？模板化？

- Many eyeball fallacy. misbelief. 开源，被很多人看，但实际真的会看吗？也不一定安全。

- What does decentralization mean? 分叉 -> 民主

- decentralization != distributed

互不信任的实体之间建立共识的操作，才写在智能合约中。

大规模计算还是应该用分布式计算平台。

### 美链 beauty chain

一个部署在以太坊上的智能合约，有自己的代币 BEC

ICO: Initial Coin Offering

类型上溢被攻击了，代币爆炸了。

### 总结

去中心化和中心化界限并不是黑白分明的。

适合做什么？

已有的支付方式解决的不好的问题。

跨国支付，电子货币。

互联网：信息传播网络。

价值交换呢？

Information can flow freely on the Internet, but payment cannot.

Software is eating the world?

Is decentralization always a good thing?