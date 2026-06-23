module "vpc" {

source  = "terraform-aws-modules/vpc/aws"
version = "5.8.1"

name = "wiz-demo"

cidr = "10.0.0.0/16"

azs = [
"us-east-1a",
"us-east-1b"
]

public_subnets = [
"10.0.1.0/24",
"10.0.2.0/24"
]

private_subnets = [
"10.0.11.0/24",
"10.0.12.0/24"
]

enable_nat_gateway = true

}