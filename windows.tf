# Windows Target
data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "rdp_target" {
  ami                         = data.aws_ami.windows.id
  instance_type               = "t3.small"
  key_name                    = "sap"                 # you already have this
  subnet_id                   = aws_subnet.boundary_db_demo_subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
  monitoring                  = true
  get_password_data           = true                      # <-- ADD

  # Minimal bootstrap: enable RDP + firewall (no secrets here)
  user_data = <<-POW
  <powershell>
  Set-ItemProperty "HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server" -Name "fDenyTSConnections" -Value 0
  Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
  </powershell>
  POW

  tags = { Team = "IT", Name = "rdp-target" }
}

locals {
  # NOTE: resource name must match your EC2 resource in windows.tf
  admin_password = try(
    rsadecrypt(aws_instance.rdp_target.password_data, var.admin_key_private_pem),
    var.decrypted_admin_password,
    ""
  )
}
