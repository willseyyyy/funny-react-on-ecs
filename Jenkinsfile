pipeline {
  agent any

  environment {
    AWS_REGION = credentials('aws-region')        // string credential
    AWS_ACCOUNT_ID = credentials('aws-account-id')// string credential
    ECR_REPO = 'funny-react-on-ecs'
    IMAGE_TAG = "${env.BUILD_NUMBER}"
    // AWS creds must be configured on Jenkins (with access to ECR/ECS)
    // using the Jenkins 'Amazon Web Services Credentials' plugin or as username/password.
    // Here we expect standard env vars to be available after withCredentials.
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Node Build & Test') {
      tools { nodejs 'node18' }
      steps {
        dir('react-app') {
          sh 'npm ci || npm i'
          sh 'npm run lint'
          sh 'npm test'
          sh 'npm run build'
        }
      }
      post {
        always {
          junit allowEmptyResults: true, testResults: '**/junit*.xml'
        }
      }
    }

    stage('Docker Build') {
      steps {
        sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
      }
    }

    stage('Login to ECR & Push') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
          sh '''
            aws --version
            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
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
            ./scripts/render_taskdef.sh $AWS_ACCOUNT_ID $AWS_REGION $ECR_REPO $IMAGE_TAG > ecs/taskdef.rendered.json
            aws ecs register-task-definition --cli-input-json file://ecs/taskdef.rendered.json
          '''
        }
      }
    }

    stage('Deploy to ECS (Fargate)') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins']]) {
          sh '''
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
  }
}
