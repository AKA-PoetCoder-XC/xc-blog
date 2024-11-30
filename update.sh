#!/bin/bash

git add ./
git commit -m "Update article"
git checkout main
git pull origin main
git push origin main

./preview.sh