#!/bin/bash

# API key for Paperspace
API_KEY=$PS_API_TOKEN

# Machine creation parameters
MACHINE_TYPE="A100"
REGION="East Coast (NY2)"
OS="ML-In-a-box"
MACHINE_NAME="A100-GPU-Server"

# Paperspace API endpoint
API_ENDPOINT="https://api.paperspace.com"
MACHINE_CREATE_ENDPOINT="$API_ENDPOINT/v1/machines/create"

# Stable Diffusion setup
REPO_URL="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git"
MODEL_URL="https://sd-models.nyc3.cdn.digitaloceanspaces.com/child_illustrations_Minimalism_v2.0.safetensors"
MODEL_FILE="v1-5-pruned-emaonly.safetensors"

# Create Machine on Paperspace
response=$(curl -s -X POST "$MACHINE_CREATE_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  --data '{
    "region": "'$REGION'",
    "machineType": "'$MACHINE_TYPE'",
    "os": "'$OS'",
    "name": "'$MACHINE_NAME'"
  }')

# Extract machine IP from response
machine_ip=$(echo $response | jq -r '.ip')

# Wait for machine to initialize
echo "Waiting for the machine to initialize..."
sleep 120  # Adjust timing as necessary

# SSH and configure the machine
ssh -o StrictHostKeyChecking=no paperspace@$machine_ip << 'EOF'
  sudo apt-get update
  sudo apt-get install -y git tmux wget

  # Clone and setup Stable Diffusion
  git clone $REPO_URL
  cd stable-diffusion-webui
  echo 'export COMMANDLINE_ARGS="--api --xformers --enable-insecure-extension-access --listen --share --no-half-vae"' >> webui-user.sh

  # Replace model file
  cd models/Stable-diffusion
  rm $MODEL_FILE
  wget $MODEL_URL

  # Start web UI in tmux session
  tmux new-session -d -s stable_diffusion './webui.sh'
EOF

echo "Setup complete. Stable Diffusion is running in a tmux session on the Paperspace machine with IP: $machine_ip"
