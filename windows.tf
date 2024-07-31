
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
  user_data = <<-EOF
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

<persist>true</persist>
<powershell>
Start-Transcript -Path "C:\Windows\cloudinit.log" -Append

$path= 'HKLM:\Software\UserData'

if(!(Get-Item $Path -ErrorAction SilentlyContinue)) {
    New-Item $Path
    New-ItemProperty -Path $Path -Name RunCount -Value 0 -PropertyType dword
}

$runCount = Get-ItemProperty -Path $path -Name Runcount -ErrorAction SilentlyContinue | Select-Object -ExpandProperty RunCount

if($runCount -ge 0) {
    switch($runCount) {
        0 {
            Write-Host "Run Count is" $runCount
            $runCount = 1
            Set-ItemProperty -Path $Path -Name RunCount -Value $runCount
            Write-Host "Updated Run Count to" $runCount

            Write-Host "Setting Admin Password"
            net user Administrator "${admin_pass}"
            
            $NewPassword = ConvertTo-SecureString "${admin_pass}" -AsPlainText -Force

            Write-Host "Installing Domain Services"
            Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
            Install-ADDSForest -DomainName boundary.lab -InstallDNS -SafeModeAdministratorPassword $NewPassword -Confirm:$false
        }
        1 {
            Write-Host "Run Count is" $runCount
            $runCount = 2
            Set-ItemProperty -Path $Path -Name RunCount -Value $runCount
            Write-Host "Updated Run Count to" $runCount

            Write-Host "Installing AD Certificate Services"
            Install-WindowsFeature AD-Certificate -IncludeManagementTools
            Install-AdcsCertificationAuthority -CAType EnterpriseRootCA -CACommonName $(hostname) -Confirm:$false
            Restart-Computer -Confirm:$false  
        }
    }
}
</powershell>



EOF

  

















#user_data              = templatefile("./template_files/windows-target.tftpl", { admin_pass = var.rdp_admin_pass })
  tags = {
    Team = "IT"
    Name = "rdp-target"
  }
}
