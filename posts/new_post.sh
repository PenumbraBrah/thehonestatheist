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
explicit=${explicit:-false}

num=$(ls [^_]*.json | tail -n 1 | cut -f 1 -d '.')
let "num=num+1"

echo "{
  \"id\": \"$num\",
  \"titletext\": \"$title\",
  \"subtext\": \"$subtext\",
  \"timestamp\": {
    \"month\": \"$release_m\",
    \"day\": \"$release_d\",
    \"year\": \"$release_y\"
  },
  \"card_size\": \"medium\",
  \"card_type\": \"article\",
  \"image\": \"$picsum\",
  \"comments\": \"$enable_comment\",
  \"related\": [$related],
  \"explicit\": \"$explicit\"
}" > $num.json

touch $num.md
