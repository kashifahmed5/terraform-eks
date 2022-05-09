module "EKS_MASTER" {
  source                          = "./eks"
  VPC_ID                          = var.VPC_ID
  API_SUBNET                      = var.API_SUBNET
  CLUSTER_NAME                    = var.CLUSTER_NAME
  CLUSTER_VERSION                 = var.CLUSTER_VERSION
  API_PUBLIC_ACCESS               = var.API_PUBLIC_ACCESS
  API_PRIVATE_ACCESS              = var.API_PRIVATE_ACCESS
  ENABLED_CLUSTER_LOG_TYPES       = var.ENABLED_CLUSTER_LOG_TYPES
  CLUSTER_LOG_RETENTATION_IN_DAYS = var.CLUSTER_LOG_RETENTATION_IN_DAYS
}

module "EKS_WORKER" {
  source           = "./workers"
  INSTANCE_TYPES   = var.INSTANCE_TYPES
  VPC_ID           = var.VPC_ID
  CLUSTER_NAME     = var.CLUSTER_NAME
  ROOT_VOLUME_TYPE = var.ROOT_VOLUME_TYPE
  ROOT_VOLUME_SIZE = var.ROOT_VOLUME_SIZE
  MAX_SIZE         = var.MAX_SIZE
  MIN_SIZE         = var.MIN_SIZE
  DESIRED_SIZE     = var.DESIRED_SIZE
  WORKERS_SUBNETS  = var.WORKERS_SUBNETS

  depends_on = [
    module.EKS_MASTER
  ]
}
