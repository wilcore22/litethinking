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

# module "aws_subnet_private" {
#   source = "./module/module_aws_subnet_private"
#   name_vpc                 = var.name_vpc
#   private_subnet_cidrs      = var.private_subnet_cidrs
#   azs                      = var.azs


# }


# ### create subnet intranet ####

# module "aws_subnet_intranet" {
#   source = "./module/module_aws_subnet_private"
#   name_vpc                 = var.name_vpc
#   private_subnet_cidrs      = var.intranet_subnet_cidrs
#   azs                      = var.azs


# }


# ### create nat gateway ####

# module "aws_nat_gateway" {
#   source = "./module/module_aws_nat_gateway"

#   name_vpc                 = var.name_vpc
#   private_subnet_cidrs      = var.private_subnet_cidrs
#   public_subnet_cidrs      = var.public_subnet_cidrs
#   name                 = var.name

# }


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

#  module "aws_lb" {
#    source = "./module/module_aws_lb"
#    public_subnet_cidrs      = var.public_subnet_cidrs
#    security_group_ids   = [module.aws_security_group.security_group_id]
#    name_lb               = var.name_lb
#    lb_target_tags_map    = var.lb_target_tags_map
#    vpc_id = module.aws_vpc.aws_vpc_id
#  }




#  ### create autoescaling aws ###

#  module "aws_ec2_autoescaling" {
#    source = "./module/module_aws_ec2_autoescaling"
#    public_subnet_cidrs      = var.public_subnet_cidrs
#    security_group_ids   = [module.aws_security_group.security_group_id]
#    name               = var.name
#    image_id = var.image_id
#    instance_type = var.instance_type
#    key_name = var.key_name
#    max_size = var.max_size
#    min_size = var.min_size
#    desired_capacity = var.desired_capacity
#    asg_health_check_type = var.asg_health_check_type
#    target_group_arns = var.target_group_arns
#    aws_lb = [module.aws_lb.lb_tg_arn]
#  }


 #### create db #####

  # module "aws_rds" {
  #   source = "./module/module_aws_rds"
  #   private_group_name      = var.private_group_name
  #   security_group_ids   = [module.aws_security_group_rds.security_group_id]

  # }










