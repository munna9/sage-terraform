resource "aws_instance" "ubuntu-server" {
  count                       = var.instance_count
  # availability_zone           = data.aws_availability_zones.azs.names[count.index]
  ami                         = var.base_image
  instance_type               = var.instance_type
  associate_public_ip_address = "false"
  iam_instance_profile        = aws_iam_instance_profile.r_profile[0].name
  key_name                    = data.aws_key_pair.key-pair.key_name
  subnet_id                   = tolist(data.aws_subnet_ids.subnets.ids)[count.index % length(data.aws_subnet_ids.subnets.ids)]
  vpc_security_group_ids      = [data.aws_security_group.rstudios-sg.id]
  
  tags = {
    Name       = "Rstudio-ubuntu-server"
    created_by = "terraform"
  }
}
resource "null_resource" "reboot_agents" {
  count = var.instance_count
  triggers = {
    agent_ip = "${element(aws_instance.ubuntu-server.*.private_ip, count.index)}"
  }
  provisioner "remote-exec" {
    inline = [
            "echo 'network: {config: disabled}' | sudo tee -a /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg",
            "sudo cp /etc/netplan/50-cloud-init.yaml /etc/netplan/01-netcfg.yaml",
            "sudo mv /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bk_$(date +%Y%m%d%H%M)",
            "echo \"$(awk 'NR==14 {print \"            nameservers:\"}1' /etc/netplan/01-netcfg.yaml)\" | sudo tee /etc/netplan/01-netcfg.yaml",
            "echo \"$(awk 'NR==15 {print \"                search: [${var.ad_domain}]\"}1' /etc/netplan/01-netcfg.yaml)\" | sudo tee /etc/netplan/01-netcfg.yaml",
            "echo \"$(awk 'NR==16 {print \"                addresses: [${var.ad_nameservers}]\"}1' /etc/netplan/01-netcfg.yaml)\" | sudo tee /etc/netplan/01-netcfg.yaml",  
            "sudo netplan apply",
                  # Change Hostname
            "echo 'preserve_hostname: true' | sudo tee -a /etc/cloud/cloud.cfg",
            "sudo hostnamectl set-hostname '${var.hostname}.${var.ad_domain}'",
                  # Join Domain
            "sudo apt-get -y update", 
            "sudo apt-get install -y curl",
            "curl http://ftp.us.debian.org/debian/pool/main/r/realmd/realmd_0.16.3-1_amd64.deb --output realmd_0.16.3-1_amd64.deb",
            "sudo dpkg -i realmd_0.16.3-1_amd64.deb",
            # "echo 'APT::Acquire::Retries \"3\";' | sudo tee -a /etc/apt/apt.conf.d/80-retries",
            # "sudo apt-get update && sudo apt-get -y install realmd",
            "sudo apt-get update && sudo apt-get -y install sssd sssd-tools krb5-user",
            "sudo apt-get update && sudo apt-get -y install samba-common packagekit adcli",
            "echo ${var.passwd} | sudo realm join -U '${var.ad_adminusername}' --computer-ou='${var.ad_ou}' '${var.ad_realm}' -v" ,
            "echo \"%Domain\\ Admins@${var.ad_domain} ALL=(ALL:ALL) ALL\" | sudo tee -a /etc/sudoers",
            "ad_sudogroup=\"linux-sudo_$(hostname | tr \".\" \"\n\" | awk 'NR==1')\" && echo \"%$ad_sudogroup@${var.ad_domain} ALL=(ALL:ALL) ALL\" | sudo tee -a /etc/sudoers",
            "ad_sshgroup=\"linux-ssh_$(hostname | tr \".\" \"\n\" | awk 'NR==1')\" && echo \"ad_access_filter = (|(memberOf=${var.domain_admin_dn})(memberOf=CN=$ad_sshgroup,${var.ad_group_ou}))\" | sudo tee -a /etc/sssd/sssd.conf",
            "sudo service sssd restart",
            "sudo sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config",
            "sudo service sshd restart",
            "sudo pam-auth-update --enable mkhomedir",
            "echo DOMAIN-JOIN COMPLETED",
            "sudo apt-get -y update",
            "echo 'Waiting for Docker to be initialized........'",
            "sudo apt-get remove -y docker docker-engine docker.io",
            "sudo apt install -y python3-pip",
            "sudo apt-get install -y docker.io",        
  		      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io\n",     
            "sudo docker-compose --version",
            "sudo systemctl start docker",
            "sudo systemctl enable docker",
            "sudo systemctl status -y docker",
            "sudo curl -L {https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)} -o /usr/local/bin/docker-compose",
            "sudo chmod +x /usr/local/bin/docker-compose",
            "git clone https://github.com/sagerx/r_dev_projects.git",
            "cd ~/r_dev_projects/.devcontainer",
            "sudo docker-compose build rstudiopreview",
            "sudo docker container ps -a",
            "sudo usermod -aG docker ubuntu",
            "sudo apt-get -y update && sudo apt-get -y upgrade",
            "exit 0",
    ]
  }
  connection {
      host        = "${self.triggers.agent_ip}"
      type        = "ssh"
      port        = 22
      user        = "ubuntu"
      private_key = file(var.key_name)
      timeout     = "2m"
  }
}

resource "aws_iam_instance_profile" "r_profile" {
  count              = var.instance_count
  name               = "${var.instance_profile_name}_Instance_Profile"
  role               = aws_iam_role.r_role[0].name
    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "r_role" {
  count              = var.enabled ? 1 : 0
  name               = "${var.instance_profile_name}_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.default_role_assume[0].json

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "default_role_assume" {
  count = var.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {  
      identifiers = ["s3.amazonaws.com"]
      type        = "Service"
    }

    principals { 
    identifiers = var.list_aws_arns
      type        = "AWS"
    }
  }
}

resource "aws_iam_role_policy_attachment" "aws_policies" {
  count      = var.enabled ? length(var.aws_policies) : 0
  role       = aws_iam_role.r_role[0].id
  policy_arn = "arn:aws:iam::aws:policy/${element(var.aws_policies, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}