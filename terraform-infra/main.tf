module "vpc" {
  source      = "./modules/vpc"
  env         = var.env
  cidr_block  = var.cidr_block
}