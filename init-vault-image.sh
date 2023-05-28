#!/bin/bash

# Load environment variables from .env file
source .env

# Run Vault Docker container
docker run -v ~/.aws/credentials:/root/.aws/credentials:ro --rm -d -p 8200:8200 --name=vault --entrypoint sh  $VAULT_DOCKER_IMAGE -c "/bin/vault server -config /vault/config/vault-server.hcl"

# Wait until Vault server is ready
while true; do
    HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8200/v1/sys/health)
    if [ $HEALTH -eq 200 ]; then
        break
    fi
    echo "Waiting for Vault server to start (got response $HEALTH) ..."
    sleep 5
done

# Initialize Vault
docker exec -it vault vault operator init

