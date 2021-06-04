# IBM Cloud VPC Wireguard Instance
This repository will allow you to deploy a Wireguard VPN server in to a new or existing IBM Cloud VPC. 

## Deploy all resources

1. Copy `terraform.tfvars.example` to `terraform.tfvars`:

   ```sh
   cp terraform.tfvars.example terraform.tfvars
   ```

1. Edit `terraform.tfvars` to match your environment. See [inputs](#inputs) for available options.
1. Plan deployment:

   ```sh
   terraform init
   terraform plan -out default.tfplan
   ```

1. Apply deployment:

   ```sh
   terraform apply default.tfplan
   ```
   
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource\_group | Name of the resource group to associate with all deployed resources. | `string` | n/a | yes |
| existing\_vpc | Name of an existing VPC where resources will be deployed. If none provided a new VPC will be created. | `string` | `""` | no |
| existing\_subnet\_id | ID of an existing VPC Subnet where resources will be deployed. To use this `existing_vpc` must be set too. If none provided a new Subnet will be created. | `string` | `""` | no |
| ssh\_key | Name of an existing VPC ssh key for the region. If not provided a new key will be generated and attached to the VPC. | `string` | `""` | no |
| name | Name that will be prepended to all deployed resources. | `string` | `"wg"` | no |
