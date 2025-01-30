variable "environment" {
  type        = string
  description = "Environment name"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "aws_auth_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  description = "List of user maps to add to the aws-auth configmap"
}

variable "aws_auth_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  description = "List of role maps to add to the aws-auth configmap"
}

variable "node_group_role_arn" {
  type        = string
  description = "ARN of the EKS node group IAM role"
}
