
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

resource "aws_instance" "rdp-target" {
  ami           = data.aws_ami.windows.id
  instance_type = "t3.small"

  //key_name               = "boundary"
  monitoring             = true
  subnet_id              = aws_subnet.boundary_db_demo_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  user_data              = templatefile("./template_files/windows-target.tftpl", { admin_pass = var.rdp_admin_pass })
  tags = {
    Team = "IT"
    Name = "rdp-target"
  }
}
