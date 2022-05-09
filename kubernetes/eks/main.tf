# Enable Logging for the eks cluster.
resource "aws_cloudwatch_log_group" "logging" {
  name              = "/aws/eks/${var.CLUSTER_NAME}/cluster"
  retention_in_days = var.CLUSTER_LOG_RETENTATION_IN_DAYS
  tags = {
    Name = join(" - ", [var.CLUSTER_NAME, "logs"])
  }
}

# Create the role for EKS
resource "aws_iam_role" "eks_cluster_role" {
  name = "RoleForEKS-${var.CLUSTER_NAME}"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
POLICY
}


# Attaching role for EKS Cluster Policy
resource "aws_iam_role_policy_attachment" "eks_cluster_EKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Attaching role for EKS VPC Resource Controller
resource "aws_iam_role_policy_attachment" "eks_cluster_EKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# Create Security Group For EKS Cluster API Server.
resource "aws_security_group" "eks_cluster" {
  name        = "eks_cluster-${var.CLUSTER_NAME}"
  description = "Cluster Communication with Worker Node"
  vpc_id      = var.VPC_ID

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-EKS-Cluster"
  }
}

# Create Security group rule to access the EKS API Server.
resource "aws_security_group_rule" "EKS_Cluster_ingress_https" {
  description       = "Allow workstations to communicate with the cluster API server."
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_cluster.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# AWS EKS Cluster
resource "aws_eks_cluster" "EKS_CLUSTER" {
  name                      = var.CLUSTER_NAME
  role_arn                  = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = var.ENABLED_CLUSTER_LOG_TYPES
  version                   = var.CLUSTER_VERSION

  vpc_config {
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = var.API_PRIVATE_ACCESS
    endpoint_public_access  = var.API_PUBLIC_ACCESS
    subnet_ids              = var.API_SUBNET
  }

  depends_on = [aws_cloudwatch_log_group.logging]
}

resource "local_file" "kube_config" {
  content  = local.kubeconfig
  filename = "scripts/kubeconfig"
}
