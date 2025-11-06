#!/usr/bin/env bash
set -euo pipefail
REGION="${1:-ap-south-1}"
aws ecr create-repository --repository-name funny-react-on-ecs --region "$REGION" --image-scanning-configuration scanOnPush=true || true
