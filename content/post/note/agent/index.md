---
title: "Agent"
slug: agent
date: 2026-06-21T14:52:48+08:00
description: 
image: 
math: true
comments: true
tags: []
categories: 
    - note
---

https://learn.shareai.run/

{{% notice note 需要回答的问题%}}
agent 做了什么？ ≈ harness 是什么？
{{% /notice %}}


与 LLM交互 典型的数据结构
```python
msg = {
    "role": "user",       # 谁说的？(通常只有 user 和 assistant 两种)
    "content": [...]      # 说了啥？
}
```
content，是一个 list，每个元素称作 block

block 是一个 dict，包含 type \in {"text", "tool_use", "tool_result"} 等属性；

## Tools & Execution

### The agent loop

LLM 决定是否调用工具

```python
The entire secret of an AI coding agent in one pattern:
    while stop_reason == "tool_use":
        response = LLM(messages, tools)
        execute tools
        append results
    +----------+      +-------+      +---------+
    |   User   | ---> |  LLM  | ---> |  Tool   |
    |  prompt  |      |       |      | execute |
    +----------+      +---+---+      +----+----+
                          ^               |
                          |   tool_result |
                          +---------------+
                          (loop continues)
```
### Tool Use

更多的工具定义，更好的工具封装 TOOL_HANDLERS, dispatch 

### permission

问题：
Safety can't rely on trusting the model — it needs code: a check before every tool execution.

三类级别：

safe read, Risky local change, Forbidden pattern

allow, ask, and deny decisions 

层级式的校验

### hooks

问题：
可扩展性，优雅的在各个阶段添加更多的行为。
比如 UserPromptSubmit、PreToolUse、PostToolUse、Stop

CC 有超过 27 个 hook 事件，hookresult 14 个，在交互的各个生命周期都可以插入，实现对 调用的每一步的细粒度控制。

## Planning & Coordination

问题：
给一个复杂任务，agent 上下文注意力容易被分散。在各种工具输出中，忘记了原来的任务目标。

### TodoWrite

todo列表是一个方式，规划 — 让 Agent 在动手之前先想清楚。

### Subagent

> Break Large Tasks into Small Ones with Clean Context

通过一个 新的 task 工具形式，spawn 一个 子 agent，拥有全新的 message[]，只回传结论给 主agent。

CC 实际会存在

-  Fork 模式：共享 Prompt Cache, 和之前上下文完全一样，包括 system prompt、 tools、 model、 messages 前缀、 thinking config，必须字节级一致。
- 递归Fork保护
- Permission Bubbling
- Async vs Sync, 也可以异步开 subagent 等通知


### Skils

Inject specialized knowledge only when the task actually needs it.

按需加载，特化领域知识

层级式加载。
1. system prompt 启动注入只加 name/description。
2. 判断需要用，以某个工具调用，加载对应skill全部内容。以 tool_result 注入到 messages 中

按需加载解决了"不该提前带的不要带"

CC：
- skill 来源众多：managed/policy skills、user skills（~/.claude/skills/）、project skills（.claude/skills/）、--add-dir skills、legacy commands、dynamic skills、conditional skills（带 paths frontmatter，按文件路径激活）、bundled skills、plugin skills、MCP skills。
- 多个 Frontmatter 字段

## 记忆管理

### Context Compact

Compression keeps the conversation usable when the context window gets crowded.

usr的 (prompt 和 tool result) 和 assistant

按照重要程度，
1、tool_result_budget：排序优先处理大结果，将完整内容落盘写文件系统；
2、snip，裁剪掉中间的message: 消息超50条，保留头部3条，和尾部47条，中间裁剪掉；注意保留成对的 tool_call 和 tool_result；
3、MICRO，旧工具结果替换占位: 比如最近10个工具结果，只保留在最近3条，更旧的 result 替换成占位的
4、发起一次 LLM 调用来做摘要；

设计原则：
便宜的先跑

## 结束语

LLM 擅长文本处理, 可以在广阔的人类语料、知识库中做模仿生成

agent 需要做到更好的利用上下文, context manage , 去做特定任务下的应用。

1. 你的任务的边界是否拆解的合适； 
2. 具体的任务是否 well-defined；
3. 是否具备一套检验机制可以评估某一环或者整体的输出；

本质人和 agent 需要做的事情一样，信号的过滤与放大。

多数时候需要你总结，给出精炼浓缩的陈述。有时候又需要你足以给出更多的细节。