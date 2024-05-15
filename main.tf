terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}
provider "digitalocean" {
  token = var.do_token
}

# MongoDB Database Cluster
resource "digitalocean_database_cluster" "mongodb_cluster" {
  name       = "storyforge-mongodb"
  engine     = "mongodb"
  version    = "6"  # Ensure this version is supported in your region
  size       = "db-s-2vcpu-4gb"
  region     = "fra1"  # Match this with your app's region for reduced latency
  node_count = 1
}

# Application deployment on DigitalOcean's App Platform
resource "digitalocean_app" "test_storyforge_frontend" {
  spec {
    name   = "test-storyforge-frontend"
    region = "fra"

    service {
      name          = "test-storyforge-frontend"
      build_command = "npm run build"
      run_command = "npm start"
      http_port = "8080"

      git {
        repo_clone_url = "https://github.com/iambigmomma/storyforge.git"
        branch         = "main"
      }

      # Environment variable for MongoDB URI
      env {
        key   = "MONGODB_URI"
        value = digitalocean_database_cluster.mongodb_cluster.uri
        scope = "RUN_AND_BUILD_TIME"
        type  = "GENERAL"
      }
    }
  }
}

# Output the MongoDB URI for debugging purposes (ensure it is handled securely)
output "mongodb_uri" {
  value     = digitalocean_database_cluster.mongodb_cluster.uri
  sensitive = true
}
