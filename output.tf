output "private_ip" {
  value = aws_instance.ubuntu-server.*.private_ip
}

# output "public_ip" {
#   value = aws_instance.ubuntu-server.*.public_ip
# }
