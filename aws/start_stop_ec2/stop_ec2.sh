#!/bin/bash

PS3="停止させたいインスタンスを選んでください。何もしないときは q を押下してください > "
item=""

select item in $(aws ec2 describe-instances | jq '.Reservations[] | select(.Instances[].State.Name == "running")' | jq '.Instances[].Tags[] | select(.Key == "Name")' | jq -r '.Value')
do

  if [ "${REPLY}" = "q" ]; then
    echo "終了します."
    exit 0
  fi

  if [ -n "${item}" ]; then
    break
  else
    echo "不正な入力です."
  fi

done

echo "${item} で問題ありませんか？"
echo ""

PS3="> "

select ans in YES NO
do

  if [ "${ans}" = "NO" ]; then
    echo "終了します."
    exit 0
  fi

  if [ -n "${ans}" ]; then
    break
  else
    echo "不正な入力です."
  fi

done

### 停止
### --arg オプションでjqプログラムにシェル変数を渡す
aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances | jq --arg EC2NAME ${item} '.Reservations[] | select(.Instances[].Tags[].Value == $EC2NAME)' | jq -r '.Instances[].InstanceId')

echo "停止しました"
