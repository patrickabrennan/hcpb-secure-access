# Demonstrate secure access to compute and database targets with ephemeral brokered and injected credentials using HashiCorp Boundary and Vault

![HashiCorp Boundary Logo](https://www.hashicorp.com/_next/static/media/colorwhite.997fcaf9.svg)

## Overview

This repo demonstrates secure access to an EC2 instance, an RDS database and a Windows Server in AWS using HashiCorp Boundary. 

* For connectivity to the EC2 instance, we leverage HashiCorp Vault and the application injected credentials feature to create ephemeral, signed SSH certifcates and have Boundary inject that into the session without any human intervention.
* For connectivity to the RDS instance, again we leverage HashiCorp Vault, but this time we demonstrate brokered credentials to the end user. These DB credentials are ephemeral and have a strict TTL.
* For connectivity to the Windows Server, we leverage Boundary's native credential store where we will brokered static credential to the end user for the RDP session.

For traceability and accountability, the EC2 instance is configured to enable SSH Session Recording.

## SSH Credential Injection using HCP Boundary & Vault

This repo does the following:

1. Configures HCP Boundary.
2. Configures HCP Vault.
3. Deploy a Boundary Worker in a public network.
4. Establish a connection between the Boundary Controller and the Boundary Worker.
5. Deploy an EC2 server instance in a public subnet and is configured to trust Vault as the CA.
6. Deploy an RDS instance in a public subnet.
7. Deploy a Windows Server VM in a public subnet.


NOTE: 
> The fact that this repo deploys into a public subnet and therefore having a public IP attached to the targets is not supposed to mimic a production environment. This is purely to demonstrate some of the features in Boundary.

IMPORTANT:
> Due to the current limitation in the Boundary Terraform provider, once you have created the HCPb storage bucket after the first `terraform apply`, you need to do the following:
> 1. Comment out the code in the `hcpb-storage-bucket.tf` file.
> 2. Change the `storage_bucket_id` attribute in the `boundary_target aws` resource in the `boundary-config.tf` file to the ID of the storage bucket after it's created. (This can be found in the Boundary admin UI.)

> The reason for this is that upon a `terraform destroy`, the provider cannot successfully remove the `boundary_storage_bucket` resource and will error. You can remove this manually via the CLI if you wish.

Your HCP Boundary and Vault Clusters needs to be created prior to executing the Terraform code. For people new to HCP, a trial can be utilised, which will give $50 credit to try, which is ample to test this solution.

## tfvars Variables

The following tfvars variables have been defined in a terraform.tfvars file.

- `boundary_addr`: The HCP Boundary address, e.g. "https://xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.boundary.hashicorp.
cloud"
- `auth_method_id`: "ampw_xxxxxxxxxx"                            
- `password_auth_method_login_name`: = "loginname"
- `password_auth_method_password`:   = "loginpassword"
- `aws_vpc_cidr`:                    = "172.x.x.x/16"
- `aws_subnet_cidr`:                 = "172.31.x.x/24"
- `aws_subnet_cidr2`:                = "172.31.x.x/24"
- `aws_access`:                      = ""
- `aws_secret`:                      = ""
- `vault_addr`:                      = "https://vault-cluster-address.hashicorp.cloud:8200"
- `vault_token`:                     = "hvs.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
- `db_username`:                     = "dbadmin"
- `db_password`:                     = "dbpassword"
- `db_name`:                         = "dbname"
- `s3_bucket_name`:                  = "s3-bucket-name"
- `s3_bucket_name_tags`:             = "session-recording"
- `s3_bucket_env_tags`:              = "boundary"
- `rdp_admin_pass`:                  = "rdpadminpassword"
- `rdp_admin_username`:              = "Administrator"