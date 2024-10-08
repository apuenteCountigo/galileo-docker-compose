#!/bin/sh
set -x

# Wait for Gitea to be fully operational
max_retries=30
counter=0
while [ $counter -lt $max_retries ]; do
    if curl -s -f -u galileo_user:Galileo.12345 http://galileo-git:3080/api/v1/version; then
        echo "Gitea is up and running"
        break
    fi
    echo "Waiting for Gitea to be ready..."
    sleep 10
    counter=$((counter + 1))
done

if [ $counter -eq $max_retries ]; then
    echo "Gitea did not become ready in time"
    exit 1
fi

REPO_EXISTS=$(curl -s -o /dev/null -w "%{http_code}" -u galileo_user:Galileo.12345 \
http://galileo-git:3080/galileo_user/galileo-config)
if [ "$REPO_EXISTS" -eq 404 ]; then
  echo "Creating repository galileo-config..."
  curl -X POST "http://galileo_user:Galileo.12345@galileo-git:3080/api/v1/user/repos" \
       -H "Content-Type: application/json" \
       -d '{"name": "galileo-config", "private": false, "default_branch": "main"}'
  git clone http://galileo_user:Galileo.12345@galileo-git:3080/galileo_user/galileo-config.git
  cd galileo-config
  cp -r /repo-files/* .
  git config --global user.email "galileo_user@example.com"
  git config --global user.name "galileo_user"
  git add .
  git commit -m "Initial commit"
  git push
else
  echo "Repository galileo-config already exists, skipping creation."
fi