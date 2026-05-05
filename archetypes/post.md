---
title: "{{ replace .Name "-" " " | title }}"
slug: {{ index (split .File.Dir "/") 2 }}
date: {{ .Date }}
description: 
image: 
math: true
comments: true
tags: []
categories: 
    - {{ index (split .File.Dir "/") 1 }}
---

## 前言

## 结束语