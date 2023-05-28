#!/bin/bash

# Load environment variables from .env file
set -o allexport
source .env
set +o allexport

# Check if envsubst is available
if ! [ -x "$(command -v envsubst)" ]; then
  echo 'Error: envsubst is not installed. Please install the gettext package.' >&2
  exit 1
fi


#REPOSITORY_URL=$(aws ecr describe-repositories --region "$VAULT_REGION"--repository-names "$ECR_REPOSITORY" --query 'repositories[0].repositoryUri' --output text)

#echo "Repository URL: ${REPOSITORY_URL}"

# Substitute variables in template files
envsubst < config/vault-server.hcl.template > config/vault-server.hcl
envsubst < config/vault-kms-policy.json.template > config/vault-kms-policy.json

# Build Docker image
aws ecr get-login-password | docker login --username AWS --password-stdin "$REPOSITORY_URL"
docker buildx build --platform=linux/amd64 -t "$REPOSITORY_URL/$VAULT_IMAGE_NAME:$VAULT_IMAGE_TAG" .
docker push "$REPOSITORY_URL/$VAULT_IMAGE_NAME:$VAULT_IMAGE_TAG"
