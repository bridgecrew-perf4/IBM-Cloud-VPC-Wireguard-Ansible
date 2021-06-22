# IBM Cloud VPC Wireguard Instance
This repository will allow you to deploy a Wireguard VPN server in to a new or existing IBM Cloud VPC. 

### Generate Client Keys
In order to generate the client keys you will need to ensure you have [Wireguard](https://www.wireguard.com/install/) installed locally.

```sh
wg genkey | tee client-keys/privatekey | wg pubkey > client-keys/publickey
wg genpsk | tee client-keys/presharedkey
```
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
### Required Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ibmcloud\_api\_key | IBM Cloud API key used to deploy resources. | `string` | n/a | yes |
| name | Name that will be prepended to all deployed resources. | `string` | n/a | yes |
| region | IBM Cloud VPC region for deployed resources. | `string` | n/a | yes |
| client\_public\_key | Wireguard local client Public Key. | `string` | n/a | yes |
| client\_preshared\_key | Wireguard local client Preshared Key. | `string` | n/a | yes |
| client\_private\_key | Wireguard local client Private Key. | `string` | n/a | yes |

### Optional Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| existing\_resource\_group | Name of an existing resource group to associate with all deployed resources. If none provided, one will be created for you. | `string` | n/a | no |
| existing\_vpc\_name | Name of an existing VPC where resources will be deployed. If none provided a new VPC will be created. | `string` | n/a | no |
| existing\_subnet\_name | Name of an existing VPC Subnet where resources will be deployed. To use this `existing_vpc_name` must be set too. If none provided a new Subnet will be created. | `string` | n/a | no |
| existing\_ssh\_key | Name of an existing VPC ssh key for the region. If not provided a new key will be generated and attached to the VPC. | `string` | n/a | no |
| allow\_ssh\_from | An IP address, a CIDR block, or a single security group identifier to allow incoming SSH connection to the bastion instance. | `string` | `0.0.0.0/0` | no |
| create\_public\_ip | Set whether to allocate a public IP address for the bastion instance. | `bool` | `true` | no |
| tags | Default tags to add to all resources. | `list(string)` | `terraform` | no |
| existing\_bastion\_instance| Name of an existing Bastion server to use with Ansible. If not provided a bastion instance will be created. | `string` | n/a | no |

## Outputs
| Name | Description | 
|------|-------------|
| bastion\_public\_ip | Public IP of the Bastion instance | 
| wireguard\_public\_ip | Public IP of the Wireguard instance | 
| instance\_private\_ip | Private IP of the test instance (if created) | 