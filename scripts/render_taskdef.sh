#!/usr/bin/env bash
set -euo pipefail
ACC="$1"; REG="$2"; REPO="$3"; TAG="$4"
sed -e "s#<AWS_ACCOUNT_ID>#$ACC#g"     -e "s#<AWS_REGION>#$REG#g"     -e "s#<ECR_REPO>#$REPO#g"     -e "s#<IMAGE_TAG>#$TAG#g"     -e "s#<EXECUTION_ROLE_ARN>#arn:aws:iam::$ACC:role/ecsTaskExecutionRole#g"     -e "s#<TASK_ROLE_ARN>#arn:aws:iam::$ACC:role/ecsTaskBasicRole#g"   ecs/taskdef.json
