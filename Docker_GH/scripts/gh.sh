#!/bin/bash

# Replace these
USERNAME=<Your_Github_Username>
TOKEN=<Github_nginx_token>

#Max page is 100
PERPAGE=100

# User base URL
BASEURL="https://nginx.github.com/user/<your_github_username>/repos"

# Calculating the Total Pages after enabling Pagination
TOTALPAGES=`curl -I -i -u $USERNAME:$TOKEN -H "Accept: application/vnd.github.v3+json" -s ${BASEURL}\?per_page\=${PERPAGE} | grep -i link: 2>/dev/null|sed 's/link: //g'|awk -F',' -v  ORS='\n' '{ for (i = 1; i <= NF; i++) print $i }'|grep -i last|awk '{print $1}' | tr -d '\<\>' | tr '\?\&' ' '|awk '{print $3}'| tr -d '=;page'`
i=1
until [ $i -gt $TOTALPAGES ]
do
  result=`curl -s -u $USERNAME:$TOKEN -H 'Accept: application/vnd.github.v3+json' ${BASEURL}?per_page=${PERPAGE}\&page=${i} 2>&1`
  echo $result > tempfile
  echo "Repo Name, SSH URL, Clone URL"
  cat tempfile|jq '.[]| [.name, .ssh_url, .clone_url]| @csv'|tr -d '\\"'
  ((i=$i+1))
done
