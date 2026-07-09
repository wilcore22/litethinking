#### create vpc #####
module "aws_vpc" {
  source = "./module/module_aws_vpc"

  create_vpc           = var.create_vpc
  create_igw           = var.create_igw
  name                 = var.name
  cidr                 = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

}


### create subnet public ####

module "aws_subnet_public" {
  source = "./module/module_aws_subnet_public"
  vpc_id              = module.aws_vpc.vpc_id
  public_subnet_cidrs      = var.public_subnet_cidrs
  azs                      = var.azs


}

### create route subnet public ####

module "aws_route_subnet_public" {
  source = "./module/module_aws_route_subnet_public"
  vpc_id              = module.aws_vpc.vpc_id
  subnet_ids          = module.aws_subnet_public.subnet_ids
  internet_gateway_id = module.aws_vpc.internet_gateway_id
}

# ### create subnet private ####

 module "aws_subnet_private" {
   source = "./module/module_aws_subnet_private"
   vpc_id              = module.aws_vpc.vpc_id
   private_subnet_cidrs      = var.private_subnet_cidrs
   azs                      = var.azs

}


# ### create subnet intranet ####

 module "aws_subnet_intranet" {
   source = "./module/module_aws_subnet_private"
   vpc_id              = module.aws_vpc.vpc_id
   private_subnet_cidrs      = var.intranet_subnet_cidrs
   azs                      = var.azs


 }


# ### create nat gateway ####

 module "aws_nat_gateway" {
   source = "./module/module_aws_nat_gateway"

  vpc_id              = module.aws_vpc.vpc_id
  public_subnet_ids   = module.aws_subnet_public.subnet_ids
  private_subnet_ids  = module.aws_subnet_private.subnet_ids
  intranet_subnet_ids = module.aws_subnet_intranet.subnet_ids

 }


 #### create security group ######

 module "aws_security_group" {
   source = "./module/module_aws_security_group"

   vpc_id              = module.aws_vpc.vpc_id
   egress_rules          = var.egress_rules
   ingress_rules         = var.ingress_rules
   name_sg               = var.name_sg

 }


 #### create ec2 ######

  module "ec2_new" {
    source = "./module/module_aws_ec2"
    ami               = var.ami
    azs = var.azs
    subnet_ids          = module.aws_subnet_public.subnet_ids
    security_group_ids   = [module.aws_security_group.security_group_id]
    user_data_filepath       = var.user_data_filepath
  }


#  ### create lb aws ###

module "aws_alb" {
  source = "./module/module_aws_lb"
  name_lb             = "alb-litethinking"
  vpc_id              = module.aws_vpc.vpc_id
  subnet_ids          = module.aws_subnet_public.subnet_ids
  security_group_ids  = [module.aws_security_group.security_group_id]
}




#  ### create autoescaling aws ###

module "aws_asg" {
  source = "./module/module_aws_ec2_autoescaling"

  name               = "asg-litethinking"
  image_id           = var.ami
  instance_type      = "t2.micro"
  key_name           = var.key_name
  security_group_ids = [module.aws_security_group.security_group_id]
  
  
  subnet_ids         = module.aws_subnet_private.subnet_ids
  
  
  target_group_arns  = [module.aws_alb.target_group_arn]

  min_size           = 1
  max_size           = 3
  desired_capacity   = 2
}


 #### create db #####

module "aws_security_group_db" {
  source = "./module/module_aws_security_group"

  name_sg       = "sg-rds-mysql"
  vpc_id        = module.aws_vpc.vpc_id
  ingress_rules = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_block  = var.cidr
      description = "Acceso MySQL desde VPC"
    }
  ]
  egress_rules  = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
      description = "Salida general"
    }
  ]
}










