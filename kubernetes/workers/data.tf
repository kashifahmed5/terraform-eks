# data "template_file" "userdata" {
#   template = file("${path.module}/templates/userdata.tmpl.sh")

#   vars = {
#     cluster_auth_base64 = var.CLUSTER_AUTH_BASE64
#     endpoint            = var.CLUSTER_ENDPOINT
#     cluster_name        = var.CLUSTER_NAME
#     pre_userdata        = var.PRE_USERDATA
#     additional_userdata = var.ADDITIONAL_USERDATA
#   }
# }

data "template_file" "configmap" {
  template = file("${path.module}/templates/aws-auth.tmpl.yaml")

  vars = {
    "role_arn" = aws_iam_role.eks_node.arn
  }
}

