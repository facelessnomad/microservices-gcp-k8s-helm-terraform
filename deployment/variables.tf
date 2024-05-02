# HELM VARIABLES
variable "kube_config_path" {
  type        = string
  description = "Kube config path"
  default     = "~/.kube/config"
}

# variable "config_context_cluster" {
#   type        = string
#   description = "Config context cluster"
# }

# GKE VARIABLES
variable "project_id" {
  type        = string
  description = "Project name"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "gke_num_nodes" {
  type        = number
  description = "(optional) describe your variable"
}