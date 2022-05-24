# IBM Cloud VPC Wireguard Instance
This repository will allow you to deploy a Wireguard VPN server in to a new or existing IBM Cloud VPC. 

## Overview

## Pre-Reqs

- [Wireguard][wireguard] installed locally.
- An [IBM Cloud API Key][api-key].
- A [VPC SSH Key][vpc-ssh-key] in the region you will be deploying the Wireguard instance.

## Create Empty Wireguard Tunnel on Client Machine

In order to generate the client keys you will need to ensure you have .

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
| client\_peer\_allowed\_ips | The local subnet allowed on the remote side of the connection. For example: 192.168.0.0/24. | `string` | n/a | yes |

### Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| existing\_resource\_group | Name of an existing resource group to associate with all deployed resources. If none provided, one will be created for you. | `string` | n/a | no |
| existing\_vpc\_name | Name of an existing VPC where resources will be deployed. If none provided a new VPC will be created. | `string` | n/a | no |
| existing\_subnet\_name | Name of an existing VPC Subnet where resources will be deployed. To use this `existing_vpc_name` must be set too. If none provided a new Subnet will be created. | `string` | n/a | no |
| existing\_ssh\_key | Name of an existing VPC ssh key for the region. If not provided a new key will be generated and attached to the VPC. | `string` | n/a | no |
| allow\_ssh\_from | An IP address or CIDR block that is allowed to connect to the Wireguard Instance tunnel. | `string` | `0.0.0.0/0` | no |
| allow\_tunnel\_from | An IP address, a CIDR block, or a single security group identifier to allow incoming SSH connection to the bastion instance. | `string` | `0.0.0.0/0` | no |
| tags | Default tags to add to all resources. | `list(string)` | `terraform` | no |

## Outputs

| Name | Description | 
|------|-------------|
| wireguard\_public\_ip | Public IP of the Wireguard instance | 
| wireguard\_private\_ip | Private IP of the Wireguard instance | 
| podman\_private\_ip | Private IP of the podman test instance | 

[wireguard]: https://www.wireguard.com/install/
[vpc-ssh-key]: https://example.org
[api-key]: https://example.org