# DEPLOY24 - Storyforge Deployment Guide

This guide provides detailed instructions for setting up and deploying my application using Paperspace for GPU computing, MongoDB as a database, and a web application platform managed via Terraform on DigitalOcean.

## Prerequisites

Before you begin, ensure you have the following:

- A DigitalOcean account
- A Paperspace account
- Terraform installed on your local machine
- Git installed on your local machine
- DigitalOcean CLI installed on your local machine
- Paperspace CLI installed on your local machine

## Step 1: Set Up a Paperspace GPU Machine

1. **Manual Setup**:
   - Visit the [Paperspace Console](https://www.paperspace.com/console).
   - Manually create a new GPU machine with the following specifications:
     - **GPU Type**: Choose an available GPU (e.g., A100).
     - **Storage**: 200GB
     - **OS**: Preferably a Linux distribution such as Ubuntu.

Ensure the machine is running before proceeding to the next steps.

## Step 2: Configure the Paperspace Machine

Once your machine is up and running, you'll need to prepare it for running Stable Diffusion.

### Installation Script

Run the following script on your Paperspace machine to set up the environment for Stable Diffusion:

```bash
#!/bin/bash
# This script sets up the Stable Diffusion web UI on your GPU machine.

# Update and install necessary packages
sudo apt-get update
sudo apt-get install -y git tmux wget

# Clone the Stable Diffusion web UI repository
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui

# Download the model file
wget -P models/Stable-diffusion https://sd-models.nyc3.cdn.digitaloceanspaces.com/child_illustrations_Minimalism_v2.0.safetensors

# Run the web UI in a new tmux session
tmux new-session -d -s stable_diffusion './webui.sh'
```

### Automate the Script at Reboot

To ensure the web UI automatically starts at every reboot, add the following entry to your crontab:

```bash
crontab -e
```

Then add the following line:

```bash
@reboot /usr/bin/tmux new-session -d -s stable_diffusion '~/stable-diffusion-webui/webui.sh'
```

## Step 3: Deploy MongoDB Cluster and Web Application via Terraform

This step involves deploying a MongoDB cluster and a web application platform using Terraform, which will automate the setup on DigitalOcean.

### Prerequisites for Terraform

Ensure Terraform is installed on your local machine. If not already installed, you can download and install Terraform from [Terraform's official website](https://www.terraform.io/downloads.html).

### Clone the Terraform Configuration Repository

If you have not already cloned the Terraform configuration repository, clone it now with:

\```bash
git clone https://your_repository_url_here
cd path_to_your_terraform_configuration
\```

### Initialize Terraform

Navigate to your Terraform configuration directory and run the following command to initialize Terraform, which will download necessary providers and initialize the state file:

```bash
terraform init
```

### Deploy the Infrastructure

To deploy both the MongoDB cluster and the app platform, execute the following command. This will read your Terraform configuration files, apply them, and start the provisioning of resources on DigitalOcean:

```bash
terraform apply
```

You will be prompted to confirm the action before Terraform creates the resources. Type `yes` to proceed.

### Verify Deployment

Once Terraform has successfully applied the configuration, it will output the MongoDB URI and any other relevant information. Ensure that the MongoDB cluster and app platform are running correctly by logging into your DigitalOcean dashboard.

## Conclusion

Your MongoDB cluster and web application should now be fully set up and operational. The web application will be configured to connect to the MongoDB cluster using the URI provided by Terraform.

## Support

For additional help or feedback, open an issue in this repository, and we'll get back to you as soon as possible.
