#!/bin/bash


# Ensures script stops immediately on any unexpected sub-command failure
set -e

echo '---Updating kubeconfig for EKS cluster---'
aws eks update-kubeconfig --region ${AWS_REGION} --name ${K8S_CLUSTER_NAME}

kubectl get nodes

# Create this namespace if it doesn't exist, but don't fail if it already does.
kubectl create namespace ${K8S_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Creates isolated workspace folder for final substituted deployment manifests
mkdir -p k8s/rendered

# Exporting core environment tokens to pass smoothly down into envsubst
export IMAGE_TAG=${APP_VERSION}
export IMAGE_NAME=${IMAGE_NAME}
export ECR_REGISTRY=${ECR_REGISTRY}
export K8S_NAMESPACE=${K8S_NAMESPACE}

echo '---Rendering Declarative Manifest Tokens---'
envsubst < k8s/deployment.yml > k8s/rendered/deployment.yml
envsubst < k8s/svc.yml > k8s/rendered/svc.yml

echo "---Rendered Deployment---"
cat k8s/rendered/deployment.yml

kubectl apply -f k8s/rendered/ -n ${K8S_NAMESPACE}

echo "---Waiting for rollout---"
kubectl rollout status deployment/pro-app -n ${K8S_NAMESPACE} --timeout=180s

echo "---Rollout finished---"
