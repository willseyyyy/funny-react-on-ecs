# Architecture: GitHub → Jenkins → ECR → ECS (Fargate) → CloudWatch

```mermaid
flowchart LR
  dev[Developer pushes to GitHub] --> webhook[GitHub Webhook]
  webhook --> jenkins[Jenkins Pipeline]

  subgraph CI
    jenkins --> NPM[Build + Lint + Test (npm)]
    NPM --> dockerBuild[Docker Build]
    dockerBuild --> ecr[ECR Push]
  end

  subgraph CD
    ecr --> taskdef[Register Task Definition]
    taskdef --> ecs[ECS Service (Fargate)]
  end

  ecs -->|App Logs| cw[(CloudWatch Logs)]
  user((User Browser)) -->|HTTP :80| ecs
```
