resource "aws_instance" "boundary_public_target" {
  ami               = var.aws_ami
  instance_type     = "t2.micro"
  availability_zone = var.availability_zone
  #user_data_base64  = data.cloudinit_config.ssh_trusted_ca.rendered
  user_data = <<-EOF
#!/bin/bash
sudo bash -c 'curl -o /etc/ssh/trusted-user-ca-keys.pem \
--header "X-Vault-Namespace: admin" \
-X GET \
${var.vault_addr}/v1/ssh-client-signer/public_key'
sudo bash -c 'echo TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem >> /etc/ssh/sshd_config'
sudo bash -c 'systemctl restart sshd.service'
EOF


  network_interface {
    network_interface_id = aws_network_interface.boundary_public_target_ni.id
    device_index         = 0
  }
  tags = {
    Name         = "boundary-1-dev",
    service-type = "database",
    application  = "dev",
  }
}

resource "aws_network_interface" "boundary_public_target_ni" {
  subnet_id               = aws_subnet.boundary_db_demo_subnet.id
  security_groups         = [aws_security_group.allow_all.id]
  private_ip_list_enabled = false
}

//Configure the EC2 host to trust Vault as the CA
#data "cloudinit_config" "ssh_trusted_ca" {
#  gzip          = false
#  base64_encode = true

#  part {
#    content_type = "text/x-shellscript"
#    content      = <<-EOF
#    sudo bash -c 'curl -o /etc/ssh/trusted-user-ca-keys.pem \
#    --header "X-Vault-Namespace: admin" \
#    -X GET \
#    ${var.vault_addr}/v1/ssh-client-signer/public_key'
#    sudo bash -c 'echo TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem >> /etc/ssh/sshd_config'
#    sudo bash -c 'systemctl restart sshd.service'
#    EOF
#  }

 # part {
 #   content_type = "text/x-shellscript"
 #   content      = <<-EOF
 #   sudo bash -c 'adduser admin_user'
 #   sudo nash -c 'adduser danny'
 #   EOF
 # }
#}
