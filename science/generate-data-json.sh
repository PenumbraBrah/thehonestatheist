#!/bin/bash
# jq '{ (.id): . }' `ls *.json` 2> /dev/null | jq -s . 2> /dev/null |\
# add readable date
jq '. |= . + { "readbl_date": (.timestamp.month + " " + .timestamp.day + ", " + .timestamp.year) }' `ls [^_]*.json | sort -gr` |\
# add latest post bool
jq '. |= . + { "latest_post": "no" }' |\
# add oldest post bool
jq '. |= . + { "oldest_post": "no" }' |\
# flatten metadata
jq -s . |\
# format with id as key
jq 'map( { (.id|tostring): . } ) | add' > _data.json.tmp
# sed '$ d' | sed "1 d" | jq . | cat > _data.json
tac _data.json.tmp | sed '3 s/"no"/"yes"/' | tac |\
perl -pe 's{no}{++$n == 1 ? "yes" : $&}ge' > _data.json
rm -f _data.json.tmp 2> /dev/null
head _data.json
echo "..."
tail _data.json
