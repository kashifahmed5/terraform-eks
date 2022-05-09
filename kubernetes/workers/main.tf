resource "aws_iam_role" "eks_node" {
  name = "eks_worker_node-${var.CLUSTER_NAME}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
      }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "EKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "EKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "EC2Registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy" "policy" {
  name = "${var.CLUSTER_NAME}_scaler_policy"
  role = aws_iam_role.eks_node.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "local_file" "rendered_confitmap" {
  content  = data.template_file.configmap.rendered
  filename = "${path.root}/scripts/aws-auth-configmap.yaml"
}

# EKS node Group for eks
resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.CLUSTER_NAME
  node_group_name = var.CLUSTER_NAME
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.WORKERS_SUBNETS
  instance_types  = var.INSTANCE_TYPES
  disk_size       = var.ROOT_VOLUME_SIZE
  labels = {
    "nodegroup" = "on-demand"
  }
  scaling_config {
    desired_size = var.DESIRED_SIZE
    max_size     = var.MAX_SIZE
    min_size     = var.MIN_SIZE
  }
}
