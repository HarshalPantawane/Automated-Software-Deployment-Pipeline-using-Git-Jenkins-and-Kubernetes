pipeline {
    agent any

    
    environment {
        // Dynamic Image Versioning using Jenkins Build Number
        APP_VERSION = "${env.BUILD_NUMBER}"

        // Kubernetes Namespace to deploy the application
        K8S_NAMESPACE = 'production'

        // Application Image Name 
        IMAGE_NAME = 'pro-app-img'

        // Account ID for ECR registry
        ECR_REGISTRY = credentials('ecr-registry-id')

        // AWs Credential for Image store and Kubernetes deployment
        AWS_CREDENTIALS_ID = 'AWS_CREDENTIALS_ID'

        // AWS Region
        AWS_REGION = 'us-east-1'

        // Kubernetes Cluster Name
        K8S_CLUSTER_NAME = 'automation-cluster'
    }

    stages {
        stage('Dynamic Checkout') {
            steps {
                echo "--- Processing Repository: ${env.REPO_NAME} | Branch: ${env.GIT_BRANCH} ---"
                // Pulls down the code for your specific repo/branch that triggered the webhook
                checkout scm
            }
        }
        stage('Maven Build') {
            steps {
                // Using -B for batch mode to avoide progress bars
                sh """
                echo '--- Building Application ---'    
                mvn -B clean package
                echo '--- Application Built Successfully ---'
                """
            }
        }
        stage('Maven Test') {
            steps {
                sh """
                echo '--- Executing test cases ---'
                mvn -B test
                echo '--- Test cases executed successfully ---'
                """
            }
        }
        stage('Build & Tag Image') {
            steps {
                sh """
                echo '--- Building Docker image ---'
                docker build -t ${IMAGE_NAME}:${APP_VERSION} .
                echo '--- Docker image built successfully ---'

                echo '---Image Tag---'
                docker tag ${IMAGE_NAME}:${APP_VERSION} ${ECR_REGISTRY}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${APP_VERSION}
                echo '---Image Taged Successfully---'
                """
            }
        }
        stage('Login And Push Image') {
            steps {
                // Using Jenkins Credential to login and push image to ECR
                withCredentials([usernamePassword(credentialsId: env.AWS_CREDENTIALS_ID, usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh """
                    echo '--- Login to ECR ---'
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    echo '--- Login successful ---'

                    echo '---Describe and Create ECR Repository---'
                    aws ecr describe-repositories --repository-name ${IMAGE_NAME} --region ${AWS_REGION} >/dev/null 2>&1 ||
                    aws ecr create-repository --repository-name ${IMAGE_NAME} --region ${AWS_REGION}
                    echo '---Created Repository Successfully---'

                    echo '--- Pushing image to ECR ---'
                    docker push ${ECR_REGISTRY}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${APP_VERSION}
                    echo '--- Image pushed successfully ---'
                    """
                }
            }
        }

        stage('Deploy To Kubernetes') {
            steps {
                script {
                    echo '--- Deploying to Kubernetes ---'
                    // Using Jenkins Credential to authenticate with AWS and deploy to EKS cluster
                    withCredentials([
                        usernamePassword(
                            credentialsId: env.AWS_CREDENTIALS_ID,
                            usernameVariable: 'AWS_ACCESS_KEY_ID',
                            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                        )
                    ]) {
                       chmod +x deploy.sh
                       sh './deploy.sh'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment to Kubernetes was successful!'
        }

        failure {
            echo 'Pipeline failed. Checking for errors...'
        }
    }
}