variable "initials" {
  description = "Enter your initials to include in URLs. Lowercase only!!!"
  default     = "tm"
}

variable "region" {
  description = "The AWS region where all resources in this example should be created"
  default     = "eu-west-1"
}

variable "cluster_base_name" {
  description = "The name of the EKS cluster"
  default     = "demo-k8s-operator"
}

# The following variables are used in eks.tf to assign your AWS IAM role to the 
# EKS auth role / iamidentitymapping. This enables access to browse the cluster 
# resources in the AWS console.
# The Role you are looking for can be found at the top right of the AWS console, 
# and looks like this:
# "AWSReservedSSO_SEs_Administrators_89b10ea4d41d0914/taylor.mowat@contrastsecurity.com"
variable "aws_account_id" {
  description = "Your AWS account ID. "
  default     = "771960604435"
}
variable "aws_iam_role_name" {
  description = "Your user's AWS IAM role name."
  default     = "AWSReservedSSO_SEs_Administrators_89b10ea4d41d0914"
}
