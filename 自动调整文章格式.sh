#!/bin/bash

# 定义变量
file_path="./_posts/new-article.md"
github_repo="https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main"

# 使用 sed 命令进行替换
# 注意：这里使用了 -i 选项直接修改原文件，以及 -E 启用扩展正则表达式
sed -i 's|\.\.\\img\\|https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/|g' $file_path
sed -i 's|\.\./img/|https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/|g' $file_path
sed -i 's|](.*\\img\\|](https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img/|g' $file_path

# 确认替换操作完成
echo "文件 '$file_path' 中的图片链接已更新。"

# 从文件中提取title和date
title=$(grep 'title:' $file_path | sed 's/.*"\(.*\)".*/\1/')
echo 'title:'$title
date=$(grep 'date:' $file_path | sed 's/.*: //')
echo 'date':$date

# 构建新文件名
new_filename="./_posts/${date}-${title}.md"
echo $new_filename

# 重命名文件
mv "$file_path" "${new_filename}"
