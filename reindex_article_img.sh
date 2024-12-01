#!/bin/bash

# 定义变量
file_path="./_posts/new-article.md"
github_repo="https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main"

# 使用 sed 命令进行替换
# 注意：这里使用了 -i 选项直接修改原文件，以及 -E 启用扩展正则表达式
sed -i 's|\.\./img|https://raw.githubusercontent.com/AKA-PoetCoder-XC/xc-blog/main/img|g' $file_path


# 确认替换操作完成
echo "文件 '$file_path' 中的图片链接已更新。"

# 如果需要，可以在此处添加其他操作，如提交到 Git 仓库等