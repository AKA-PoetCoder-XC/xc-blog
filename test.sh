#!/bin/bash

# 捕获命令的输出
title=$(grep 'title' ./_posts/new-article.md | sed 's/.*"\(.*\)".*/\1/')

# 打印变量
echo "捕获的标题是: $title"
   