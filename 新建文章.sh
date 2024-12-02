#!/bin/bash

# 获取当前日期
current_date=$(date +%Y-%m-%d)

# 定义文件路径
file_path="./_posts/new-article.md"

# 自定义文章编辑软件目录
editor_path="D:/Typora/Typora.exe"

# 创建并写入文件内容
cat <<EOF > "$file_path"
---
title: "新标题"
date: $current_date
---
EOF

# 确认文件已创建
echo "文件 '$file_path' 已成功创建并初始化。"

# 打开文件
$editor_path $file_path &

# 且


# 退出控制台
exit