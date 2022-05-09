variable "CLUSTER_NAME" {
  type        = string
  description = "Name for the eks cluster."
}
variable "API_SUBNET" {
  type        = list(string)
  description = "List of the subnets for the EKS api server."
}
variable "VPC_ID" {
  type        = string
  description = "VPC ID of the vpc where the cluster will be."
}

variable "CLUSTER_VERSION" {
  default     = "latest_version"
  type        = string
  description = "Kubernetes version in EKS."
}

variable "API_PUBLIC_ACCESS" {
  default = true
  type    = bool
}

variable "API_PRIVATE_ACCESS" {
  type    = bool
  default = true
}

variable "ENABLED_CLUSTER_LOG_TYPES" {
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "CLUSTER_LOG_RETENTATION_IN_DAYS" {
  default = 7
}
