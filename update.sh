#!/bin/bash

git add ./
git commit -m "update article"
git checkout main
git pull origin main
git push origin main

./preview.sh