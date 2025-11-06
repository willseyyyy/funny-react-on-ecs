
# Funny React on AWS – CI/CD with Jenkins, Docker, ECR, and ECS (Fargate)

A minimal, cheerful React app + production-ready CI/CD on AWS. Push commit → Jenkins builds/tests → Docker image → ECR → ECS deploy → CloudWatch logs.

---

## 0) Prereqs
- AWS account with admin for setup (then least-privilege later)
- ECR, ECS Fargate, VPC with 2 public subnets, security group open on :80
- Jenkins with:
  - Docker-in-Docker or Docker socket access
  - AWS CLI installed
  - NodeJS tool named `node18`
  - Email-ext plugin (or swap to SNS)
  - Credentials:
    - `aws-jenkins` (AWS credentials)
    - `aws-region` (String, e.g. `ap-south-1`)
    - `aws-account-id` (String, e.g. `123456789012`)

## 1) Clone this repo
```bash
git clone <your-fork-url>
cd aws-react-cicd-starter
```

## 2) One-time AWS setup
```bash
./scripts/create_ecr.sh ap-south-1
aws logs create-log-group --log-group-name /ecs/funny-react --region ap-south-1 || true
# Create cluster, VPC/subnets, security group, and roles as per ecs/README.md
```

Register the first task definition and create the service (see `ecs/README.md`).

## 3) Jenkins Pipeline
- Create a Multibranch Pipeline or Pipeline job pointing to your repo.
- Add GitHub webhook to trigger on push/PR.
- Ensure the credentials mentioned above exist.
- The included `Jenkinsfile` has stages:
  - Checkout
  - Node Build & Test (lint + vitest)
  - Docker Build
  - ECR Login & Push
  - Register Task Definition
  - Deploy to ECS (force new deployment)

## 4) Docker
Multi-stage build: Node 18 (build) → Nginx (serve static).

## 5) Monitoring & Alerts
- Logs: CloudWatch group `/ecs/funny-react`
- Uptime: Add an ALB health check or Route53 health checks
- Alerts: CloudWatch Alarms → SNS → email

## 6) Useful Commands
```bash
# Local test
cd react-app && npm i && npm run dev

# Local prod preview
npm run build && npm run preview

# Build and run Docker locally
docker build -t funny-react:local .
docker run -p 8080:80 funny-react:local
```

## 7) Submission Hints
- **Architecture Diagram**: See `ARCHITECTURE.md` (Mermaid)
- **Screenshots**:
  - Jenkins stages: after a run, capture the stage view / console results
  - Docker image in ECR: AWS Console → ECR → your repo
  - App running: copy the public service URL (ALB or public IP) in browser
  - Jenkinsfile: open `Jenkinsfile` in GitHub and screenshot

Happy shipping! 🛳️
