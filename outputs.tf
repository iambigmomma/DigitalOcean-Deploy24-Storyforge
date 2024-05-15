output "mongodb_cluster_uri" {
  value     = digitalocean_database_cluster.mongodb_cluster.uri
  sensitive = true
}