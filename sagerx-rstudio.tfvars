#Domain-Join
ad_adminusername  = "svc_DomainJoin"
hostname          = "rstudio-yoni"
ad_realm          = "CORP.COM"
ad_domain         = "corp.com"
ad_nameservers    = "10.220.40.30, 10.220.41.30"
ad_ou             = "OU=RStudio,OU=AWS,OU=Servers,OU=Sage,DC=corp,DC=com"
domain_admin_dn   = "CN=Domain Admins,CN=Builtin,DC=corp,DC=com"
ad_group_ou       = "OU=Security Groups,OU=Sage Secured,DC=corp,DC=com"
# passwd            = "***************"
# **************************************************************

# aws values

aws_region        = "us-east-1" 
profile           = "sagerx" 
instance_type     = "t2.medium" 
base_image        = "ami-01b996646377b6619" 
availability_zone = ["us-east-1a", "us-east-1b"] 
subnet_id         = ["subnet-075fbd0179cdd0679", "subnet-05a1dd3cf0782adf7"] 
security_group_id = "sg-0b641f93fdc6176d6"
vpc_id            = "vpc-0956755eff921bb56"
key_name          = "R-Studio-workstation-keypair"
instance_count    = "1"