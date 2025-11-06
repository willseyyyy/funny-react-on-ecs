#!/usr/bin/env bash
set -euo pipefail
REGION="$1"
CLUSTER="$2"
SERVICE="$3"

echo "Forcing new deployment of $SERVICE in $CLUSTER ($REGION)"
aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --force-new-deployment --region "$REGION"
aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE" --region "$REGION"
echo "Deployment complete."
