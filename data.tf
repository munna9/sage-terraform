data "aws_key_pair" "key-pair" {
  key_name = var.key_name
}

data "aws_vpc" "rstudios-vpc" {
  id = var.vpc_id
}
data "aws_availability_zones" azs {}

data "aws_subnet_ids" "subnets" {
   vpc_id = var.vpc_id
   filter {
    name   = "tag:Name"
    values = ["Private subnet 1A", "Private subnet 2A"]
  }
}

data "aws_security_group" "rstudios-sg" {
  id = var.security_group_id
}

# data "aws_subnet" "rstudios-subnet" {
#   id  = data.aws_subnet_ids.subnets.ids
#   filter {
#     name   = "tag:Name"
#     values = ["subnet-e5b1498d", "subnet-4ef8c435"]
#   }
# }