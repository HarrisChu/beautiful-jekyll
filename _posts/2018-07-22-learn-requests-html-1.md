---
layout: post
title: 学习 requests_html（一）
# subtitle: 
# image: /img/hello_world.jpeg
# bigimg:
tags: [python]
---

# 介绍

[requests_html](https://github.com/kennethreitz/requests-html) 是一个基于 [requests](https://github.com/requests/requests) 可以做 HTML parsing 的模块。以前如果想要爬取某个网页数据，简单网页可以用 requests + lxml 通过 xpath 获取数据，但是 requests 不能渲染 JavaScript。所以稍微复杂一点的页面，就需要 Headless 的浏览器，如 Phantomjs，甚至是 Selenium。

requests_html 使用了 `pyppeteer`, 一个非官方的 `puppeteer` python 实现，启用了 Chrome 来渲染 JavaScript。当有页面元素用 JavaScript 渲染时，也能通过 lxml 来获取到页面元素。

## 简单例子

使用 requests + lxml，是获取不到百度中「学术」的元素。

```python
import requests
import lxml
from lxml import html


def main():
    url = 'https://www.baidu.com'
    hao123 = '//a[@name="tj_trhao123"]'
    xueshu = '//a[@name="tj_trxueshu"]'
    r = requests.get(url)
    doc = lxml.html.fromstring(r.content.decode('utf8'))
    print(doc.xpath(hao123))
    print(doc.xpath(xueshu)) # 结果是一个空的 list， 因为「学术」是 JavaScript 渲染出来的。


if __name__ == '__main__':
    main()
```

使用 requests_html

```python
import requests
import lxml
from lxml import html
from requests_html import HTMLSession

REQUESTS_HTML = True


def main():
    url = 'https://www.baidu.com'
    hao123 = '//a[@name="tj_trhao123"]'
    xueshu = '//a[@name="tj_trxueshu"]'
    if REQUESTS_HTML:
        session = HTMLSession()
        r = session.get(url)
        r.html.render()
        doc = lxml.html.fromstring(r.html.html)
    else:
        r = requests.get(url)
        doc = lxml.html.fromstring(r.content.decode('utf8'))

    print(doc.xpath(hao123))
    print(doc.xpath(xueshu))
    # 使用 requests_html 中的 lxml
    print(r.html.lxml.xpath(hao123))
    print(r.html.lxml.xpath(xueshu))

if __name__ == '__main__':
    main()
```

## 学习 requests_html

requests_html 是 kennethreitz 写的库，打算通过阅读源码，进一步了解相关内容。
阅读源码好处：

* requests_html 是单个文件，比较简单，而且很快就能看完。
* 学习 Python 3.6 相关语法，尤其是 `async` 和 `await`
* 学习 pytest 相关用法

# v0.1.0

## 依赖

查看 setup.py, 看到有下面的依赖：

* requests
* pyquery
* html2text
* fake-useragent
* parse

可以看到还没有依赖 pyppeteer, 只是用 pyquery 和 parse，更方便的解析 HTML。

## Test

没有测试用例

## 代码

代码比较简单，主要是定义了一个 HTML 的类，当用 requests 获取 response 后，通过 hook 调用 `_handle_response` 函数，为 `response` 添加了一个 HTML 实例。

HTML 类主要有三个功能：

* `find` 通过传入 CSS 选择器，返回 Element 类的列表。
* `search` 利用 parse 库，可以定义一个 template，然后返回 search 的内容。
* `links` 返回页面中的超链接列表。

## 有趣代码

### 生成器

返回列表时，都定义了一个生成器，然后 `find` 函数用 list 返回，而 `links` 用 set 返回。
`set` 比 `list` 效率高，如果可以剔除重复并且顺序无关，用 set 更专业一点。

### PyQuery

pyquery 是 Python 实现的 CSS 选择器，简单的一个例子。

```python
from pyquery import PyQuery

s = '''
    <span class="k">if</span> <span class="n">__name__</span> <span class="o">==</span> 
        <span class="s">'__main__'</span>
        <span class="p">:</span>
        <span class="n">main</span>
        <span class="p">()</span>
    </code></pre>
    </div>
    '''

p = PyQuery(s)

print(p('span.s')) # <span class="s">'__main__'</span>

```

# v0.2.0

0.1.0 比较简单，继续下个 tag

## 依赖

看到去掉了 html2text，增加了 bs4 （多了 xpath？）。

## Test

多了测试用例，先看一下具体的内容。

用了 requests 的 `mount`, 直接访问了 HTML 文件，然后测试了一下 CSS selector，links，和 xpath。有个小问题是 `test_links` 验证时没用 `assert`，写了个假的测试用例 = =。

## 代码

主要改动：

* 提取了一个公共类 `BaseParser`, Element 和 HTML 都继承于此类。
* 添加了 xpath，可以用 xpath 来查找元素。
* 为了获取 link 的绝对路径，将 url 传入 Element 中。

## 有趣代码

代码不怎么复杂，k神删了 markdown 相关，又抽象了一个基类。
优化是需要贯彻始终的，对于 Python 来说，先实现功能，再不断优化就好。

### 定义函数中的 *

Python3 中，声明函数中如果有 `*`，那么在调用时， `*` 后面的参数，是必选要输入的。

例子如下：

```python
def harris(msg, *, name):
    print('hello {0}, {1}'.format(name, msg))

harris('this is a test') # 错误
harris('this is a test', 'harris') # 错误
harris('this is a test', name='harris') # 正确
```

当然，name 也可以有默认值，有默认值调用的例子：

```python
def harris_default(msg, *, name='harris'):
    print('hello {0}, {1}'.format(name, msg))

harris_default('this is a test') # 正确
harris_default('this is a test', 'harris') # 错误
harris_default('this is a test', name='blue') # 正确
```

### 继承 requests 的 Session 类

通过继承 requests 的 Session 类，自定义 hooks，可以更方便的完成一些自定义的操作。
比如，校验每次返回的 status_code 是不是 200

```python
import requests

class MySession(requests.Session):
    def __init__(self, *args, **kwargs):
        super(MySession, self).__init__(*args, **kwargs)
        self.hooks = {'response': self._handle}

    @staticmethod
    def _handle(response,  **kwargs):
        print(response.status_code)
        assert response.status_code == 200

s = MySession()

s.get('http://www.baidu.com')
s.get('http://www.baidu.com/404')
```
可以看到第二个请求，返回了302，所以 assert 错误了。