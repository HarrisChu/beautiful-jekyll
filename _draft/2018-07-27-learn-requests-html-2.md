---
layout: post
title: 学习 requests_html（二）
# subtitle: 
# image: /img/hello_world.jpeg
# bigimg:
tags: [python]
---

# 学习 requests_html

requests_html 是 kennethreitz 写的库，打算通过阅读源码，进一步了解相关内容。
阅读源码好处：

* requests_html 是单个文件，比较简单，而且很快就能看完。
* 学习 Python 3.6 相关语法，尤其是 `async` 和 `await`
* 学习 pytest 相关用法

## v0.3.1

### 依赖

相比 v0.2.0, 没有变动

### Test

相比 v0.2.0, 没有变动

### 代码

比较简单，只是多加了一个 encoding 的处理。

## v0.4.0

### 依赖

多了 w3lib 和 pyppeteer，终于用到 pyppeteer 了

### Test

相比 v0.3.1, 没有变动。 咦，是没有补测试么？

### 代码

比较简单，只是多加了一个 encoding 的处理。

### 有趣代码