# ECS Setup Notes

Create these once (via console or CLI):

- VPC + 2 public subnets + Internet Gateway
- Security group allowing inbound 80 from 0.0.0.0/0
- ECS cluster: `funny-react-cluster` (Fargate)
- Create CloudWatch Logs group: `/ecs/funny-react`
- IAM roles:
  - **Execution role**: `ecsTaskExecutionRole` with AmazonECSTaskExecutionRolePolicy
  - **Task role**: basic (or none) for this static site

Create ECR repo:
```bash
aws ecr create-repository --repository-name funny-react-on-ecs --image-scanning-configuration scanOnPush=true
```
Create a service (first time):
```bash
aws ecs create-service   --cluster funny-react-cluster   --service-name funny-react-service   --task-definition funny-react-task   --desired-count 1   --launch-type FARGATE   --network-configuration "awsvpcConfiguration={subnets=[subnet-abc,subnet-def],securityGroups=[sg-123],assignPublicIp=ENABLED}"
```
Then the pipeline will update the task definition and force new deployments.
