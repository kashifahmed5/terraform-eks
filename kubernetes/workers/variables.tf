variable "INSTANCE_TYPES" {
  type = list(string)
}

variable "VPC_ID" {
  type        = string
  description = "VPC ID of the VPC where cluster should be."
}

variable "CLUSTER_NAME" {
  type        = string
  description = "Name of the EKS cluster."
}

variable "ROOT_VOLUME_TYPE" {
  default = "standard"
}

variable "ROOT_VOLUME_SIZE" {
  default = 50
}

variable "MAX_SIZE" {
  default = 10
}

variable "MIN_SIZE" {
  default = 6
}

variable "DESIRED_SIZE" {
  default = 8
}

variable "FORCE_DELETE" {
  default = false
}

variable "WORKERS_SUBNETS" {
  type = list(string)
}
