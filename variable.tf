variable "instance_type" {
  default = ""
}

variable "ad_adminusername" {
  default = ""
}

variable "domain_admin_dn" {
  default = ""
}

variable "ad_realm" {
  default = ""
}
variable "ad_domain" {
 default = ""
}

variable "ad_ou" {
 default = ""
}
variable "ad_group_ou" {
 default = ""
}
variable "ad_nameservers" {
  # type    = list(string)
  default = ""
}

variable "key_name" {
  default = ""
}

variable "hostname" {
  default = ""
}
variable "passwd" {
  default = ""
}
variable "instance_count" {
  default = ""
}

variable "base_image" {
  # default = "ami-0b0ea68c435eb488d"
  default = ""
}

variable "availability_zone" {
  type    = list(string)
  default = []
}

variable "subnet_id" {
  type    = list(string)
  default = []
}

variable "security_group_id" {
  default = ""
}

variable "vpc_id" {
  default = ""
}
# variable "ssh_key_name1" {
#   default = "rstudio-key1.pub"
# }

variable "aws_region" {
  default     = ""
  description = "AWS Region, defaults to us-east-1"
}
variable "profile" {
  default = ""
}

variable "shared_credentials_file" {
  description = "Profile Credentials File"
  default     = ""
}
variable "instance_profile_name" {
  description = "Instance profile name to be used to create profile, policy and role"
  default     = "rstudio_yoni_s3"
}
variable "aws_policies" {
  description = "A list of AWS policies to attach, e.g. AmazonMachineLearningFullAccess"
  type        = list(string)
  default     = ["AmazonS3ReadOnlyAccess"]
}

variable "enabled" {
  description = "Enable or disable the resources."
  type        = string
  default     = "1"
}
variable "list_aws_arns" {
  description = "A list of Assume AWS type ARNs"
  type        = list(string)
  default     = ["arn:aws:iam::970645516228:user/svc-test-user"]
}
# variable "iam_role" {
#   default = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# }