pipeline {
    agent any
    environment {
        APP_VERSION = "${env.BUILD_NUMBER}"
        K8S_NAMESPACE = 'production'
        IMAGE_NAME = "pro-app-img"
        ECR_REGISTRY = credentials('ecr-registry-id')
        AWS_CREDENTIALS_ID = 'AWS_CREDENTIALS_ID'
    }
    stages {
        stage('Maven Build') {
            steps {
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
                docker tag ${IMAGE_NAME}:${APP_VERSION} ${ECR_REGISTRY}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${APP_VERSION}
                echo '---Image Taged Successfully---'
                """
            }
        }
        stage('Login And Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.AWS_CREDENTIALS_ID, usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh """
                    echo '--- Login to ECR ---'
                    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_REGISTRY}.dkr.ecr.us-east-1.amazonaws.com
                    echo '--- Login successful ---'

                    echo '---Describe and Create ECR Repository---'
                    aws ecr describe-repositories --repository-name ${IMAGE_NAME} --region us-east-1 >/dev/null 2>&1 ||
                    aws ecr create-repository --repository-name ${IMAGE_NAME} --region us-east-1
                    echo '---Created Repository Successfully---'

                    echo '--- Pushing image to ECR ---'
                    docker push ${ECR_REGISTRY}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${APP_VERSION}
                    echo '--- Image pushed successfully ---'
                    """
                }
            }
        }

        stage('Deploy To Kubernetes') {
          steps {
                script {
                     echo '--- Deploying to Kubernetes ---'
                
                     withCredentials([
                         usernamePassword(
                             credentialsId: env.AWS_CREDENTIALS_ID,
                             usernameVariable: 'AWS_ACCESS_KEY_ID',
                             passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                          )
                    ]) {
        
                        sh """
                        set -e
        
                        aws eks update-kubeconfig --region us-east-1 --name automation-cluster
        
                        kubectl get nodes
        
                        kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
        
                        mkdir -p k8s/rendered
        
                        export IMAGE_TAG=${APP_VERSION}
                        export IMAGE_NAME=${IMAGE_NAME}
                        export ECR_REGISTRY=${ECR_REGISTRY}
        
                        envsubst < k8s/deployment.yml > k8s/rendered/deployment.yml
                        envsubst < k8s/svc.yml > k8s/rendered/svc.yml
        
                        echo "--- Rendered Deployment ---"
                        cat k8s/rendered/deployment.yml
        
                        kubectl apply -f k8s/rendered/ -n ${K8S_NAMESPACE}
        
                        echo "--- Waiting for rollout ---"
                        kubectl rollout status deployment/pro-app -n ${K8S_NAMESPACE} --timeout=180s
        
                        echo "--- Rollout finished ---"
                        """
                    }
                }
            }
        }
       post {
            success {
                echo '--- Pipeline SUCCESS ---'
                echo "Build: ${APP_VERSION}"
                echo "Image: ${ECR_REGISTRY}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${APP_VERSION}"
                echo 'Deployment completed successfully in Kubernetes'
            }
        
            failure {
                echo '--- Pipeline FAILED ---'
                echo "Build: ${APP_VERSION}"
                echo 'Check logs in Build, Docker, or Kubernetes Deploy stage'
        
                sh '''
                echo "---- Kubernetes Pod Status ----"
                kubectl get pods -n production || true
        
                echo "---- Deployment Status ----"
                kubectl get deployment -n production || true
                '''
            }
        
            always {
                echo '--- Pipeline execution finished (SUCCESS or FAILURE) ---'
                cleanWs()
            }
        }
    
}
