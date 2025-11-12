pipeline {
  agent any

  environment {
    AWS_REGION = credentials('aws-region')        // string credential (e.g. us-east-1)
    AWS_ACCOUNT_ID = credentials('aws-account-id')// string credential
    ECR_REPO = 'funny-react-on-ecs'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
  }

  options {
    // keep build logs for troubleshooting
    buildDiscarder(logRotator(daysToKeepStr: '14', numToKeepStr: '50'))
    // fail fast if pipeline is aborted
    skipDefaultCheckout()
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        // explicit checkout so we can cd into subdirs reliably
        checkout scm
      }
    }

    stage('Node Build & Test') {
      // don't rely on the Jenkins NodeJS tool; instead detect Node or install via nvm
      steps {
        dir('react-app') {
          // ensure node is present (tries to install nvm->node if missing)
          sh '''
            set -e
            echo "==> Check node"
            if command -v node >/dev/null 2>&1; then
              echo "node found: $(node -v)"
            else
              echo "node not found. Installing nvm and node 18 (requires internet access on agent)..."
              # install nvm locally for the build user (idempotent)
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash || true
              export NVM_DIR="$HOME/.nvm"
              [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
              nvm install 18
              nvm use 18
              echo "installed node: $(node -v)"
            fi

            echo "==> Installing dependencies"
            npm ci || npm i

            echo "==> Linting"
            npm run lint || true

            echo "==> Running tests (will not fail pipeline on test failures here, but you can change that)"
            npm test || true

            echo "==> Building"
            npm run build
          '''
        }
      }
      post {
        always {
          junit allowEmptyResults: true, testResults: '**/junit*.xml'
          archiveArtifacts artifacts: 'react-app/build/**', fingerprint: true, onlyIfSuccessful: false
        }
      }
    }

    stage('Docker Build') {
      steps {
        // build from project root; ensure docker daemon is available on agent
        sh '''
          set -e
          echo "==> Docker build"
          docker build -t $ECR_REPO:$IMAGE_TAG .
          docker images | grep $ECR_REPO || true
        '''
      }
    }

    stage('Login to ECR & Push') {
      steps {
        // uses AWS credentials configured in Jenkins
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
          sh '''
            set -e
            echo "==> AWS & ECR login"
            aws --version
            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

            echo "==> Tagging and pushing"
            docker tag $ECR_REPO:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
            docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
          '''
        }
      }
    }

    stage('Register Task Definition') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
          sh '''
            set -e
            echo "==> Rendering task definition"
            ./scripts/render_taskdef.sh $AWS_ACCOUNT_ID $AWS_REGION $ECR_REPO $IMAGE_TAG > ecs/taskdef.rendered.json
            echo "==> Registering task definition"
            aws ecs register-task-definition --cli-input-json file://ecs/taskdef.rendered.json
          '''
        }
      }
    }

    stage('Deploy to ECS (Fargate)') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
          sh '''
            set -e
            echo "==> Deploying to ECS cluster"
            ./scripts/deploy_to_ecs.sh $AWS_REGION funny-react-cluster funny-react-service
          '''
        }
      }
    }
  }

  post {
    success {
      emailext subject: "✅ Pipeline Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
               body: "Deployed image: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG",
               to: "you@example.com"
    }
    failure {
      emailext subject: "❌ Pipeline Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
               body: "Check Jenkins console output for details.",
               to: "you@example.com"
    }
    always {
      cleanWs()
    }
  }
}
