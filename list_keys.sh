#!/bin/bash
# list keys in bucket-list.txt

# initialize -------

uuid=$(python -c 'import uuid;print(uuid.uuid4())')

# configs ----------

max_buckets_default=200
read -p "max buckets [$max_buckets_default]: " max_buckets
max_buckets=${max_buckets:-$max_buckets_default}

max_folders_per_bucket_default=50
read -p "max folders per bucket [$max_folders_per_bucket_default]: " max_folders_per_bucket
max_folders_per_bucket=${max_folders_per_bucket:-$max_folders_per_bucket_default}

max_objs_per_folder_default=20
read -p "max objects per folder [$max_objs_per_folder_default]: " max_objs_per_folder
max_objs_per_folder=${max_objs_per_folder:-$max_objs_per_folder_default}

# logic ------------

printf "\nsession: $uuid\n\n" >&2

time head -n $max_buckets bucket-list.txt |
while read b; do
  if [[ ! -z "$b" ]]; then
    # printf "-- $b --\n\n" >&2

    folders=$(aws s3 ls "s3://$b/" | awk '{print $2}')
    echo "$folders" | head -n $max_folders_per_bucket |

    # parallel
    # xargs -n1 -P8 -I{} sh -c \
    #   "aws s3 ls --recursive \"s3://$b/{}\" | awk '{print \$4}' | sed -e \"s/^/s3\:\/\/$b\//\""
    xargs -n1 -P8 -I{} sh -c \
      "aws s3api list-objects --bucket $b --prefix {} --max-items $max_objs_per_folder | jq -r '.Contents[].Key' | sed -e \"s/^/s3\:\/\/$b\//\""

    # sequential
    # while read f; do
    #   if [[ ! -z "$f" ]]; then
    #     # aws s3 ls --recursive "s3://$b/$f" | awk '{print $4}' | sed -e "s/^/s3\:\/\/$b\//"
    #     aws s3api list-objects --bucket $b --prefix $f --max-items $max_objs_per_folder | jq -r '.Contents[].Key' | sed -e "s/^/s3\:\/\/$b\//"
    #   fi
    # done
  fi
done | tee "output-$uuid.txt"
