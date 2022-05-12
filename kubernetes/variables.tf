#variable "AWS_ACCESS_KEY" {}
#variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "us-east-1"
}

variable "API_PUBLIC_ACCESS" {
  default     = true
  type        = bool
  description = "Allow api server to be accessed using public endpoint."
}

variable "API_PRIVATE_ACCESS" {
  type        = bool
  default     = true
  description = "Allow API server to be accessed using private endpoint."
}

variable "ENABLED_CLUSTER_LOG_TYPES" {
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "CLUSTER_LOG_RETENTATION_IN_DAYS" {
  default = 7
}
# service.beta.kubernetes.io/aws-load-balancer-internal: "true"

variable "INSTANCE_TYPES" {
  type        = list(string)
  description = "List of Instance types to create the worker nodegroup."
  default     = ["t3.micro"]
}

variable "VPC_ID" {
  type        = string
  description = "VPC ID of the VPC where cluster should be."
  default     = "vpc-36f4fd53"
}

variable "CLUSTER_NAME" {
  type        = string
  description = "Name of the EKS cluster."
  default     = "EKS_CLUSTER"
}

variable "CLUSTER_VERSION" {
  default     = "1.20"
  type        = string
  description = "Kubernetes version in EKS."
}

variable "ROOT_VOLUME_TYPE" {
  default     = "standard"
  type        = string
  description = "AWS volume type to use for the Root volumes of the nodes in nodegroup."
}

variable "ROOT_VOLUME_SIZE" {
  default     = 50
  type        = number
  description = "Size of the root volume of the worker nodes."
}

variable "MAX_SIZE" {
  default     = 8
  type        = number
  description = "Maximum number of worker nodes."
}

variable "MIN_SIZE" {
  default     = 6
  type        = number
  description = "Minimum Number of worker nodes."
}

variable "DESIRED_SIZE" {
  default     = 6
  type        = string
  description = "Desired capacity of the worker nodes."
}

variable "FORCE_DELETE" {
  default = false
}

variable "WORKERS_SUBNETS" {
  type        = list(string)
  description = "List of the subnets on which the worker nodes will be on."
  default     = ["subnet-7513612c", "subnet-ccc29bbb"]
}

variable "API_SUBNET" {
  type        = list(string)
  description = "List of Subnet on which the eks api server will be on."
  default     = ["subnet-76a41c7a", "subnet-0abc2c6f"]
}
