#!/bin/bash
set -e

aws ecr describe-repositories \
  --repository-names "$IMAGE_NAME" \
  --region "$AWS_REGION" >/dev/null 2>&1 || \
aws ecr create-repository \
  --repository-name "$IMAGE_NAME" \
  --region "$AWS_REGION"

aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin "$ECR_REGISTRY"

docker tag "$IMAGE_NAME:$APP_VERSION" "$ECR_REGISTRY".dkr.ecr."$AWS_REGION".amazonaws.com/"$IMAGE_NAME:$APP_VERSION"

docker push "$ECR_REGISTRY".dkr.ecr."$AWS_REGION".amazonaws.com/"$IMAGE_NAME:$APP_VERSION"