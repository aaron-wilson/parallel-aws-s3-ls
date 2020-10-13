#!/bin/bash
# generate bucket-list.txt

aws s3 ls | awk '{print $3}' | grep '^.*$' | tee 'bucket-list.txt'
