#!/bin/bash

read -p "What is the post title? " title
title=${title:-Post title}
read -p "What is the post sub-title? " subtext
read -p "Release post in how many days? " release
release=${release:-10}
release_m=$(date -d "+$release days" +"%B")
release_d=$(date -d "+$release days" +"%d")
release_y=$(date -d "+$release days" +"%Y")

read -p "Unsplash image number or jpeg filename: " picsum
picsum=${picsum:-99}

read -p "Comments enabled [true/false]: " enable_comments
enable_comments=${enable_comments:-true}

read -p "Related posts: " related
read -p "Post is explicit? " explicit
explicit={explicit:-false}
