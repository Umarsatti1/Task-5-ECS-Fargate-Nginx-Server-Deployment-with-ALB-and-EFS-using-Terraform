module "vpc" {
    source   = "./modules/vpc"
    vpc_name = var.vpc_name
    vpc_cidr = var.vpc_cidr
}

module "ecr" {
    source        = "./modules/ecr"
    ecr_repo_name = var.ecr_repo_name
}

module "task_definition" {
    source               = "./modules/task_definition"
    ecr_repo_url         = module.ecr.ecr_repo_url
    efs_fs_id            = module.efs.efs_file_system_id
    efs_ap_id            = module.efs.efs_access_point_id
    task_exec_name       = var.task_exec_name
    efs_policy_name      = var.efs_policy_name
    logs_name            = var.logs_name
    task_definition_name = var.task_definition_name
    volume_name          = var.volume_name
}

module "efs" {
    source             = "./modules/efs"
    private_subnet_ids = module.vpc.private_subnets
    security_group_id  = module.vpc.efs_sg_id
    token              = var.token
    efs_name           = var.efs_name
    access_point_name  = var.access_point_name
}

module "ecs" {
    source              = "./modules/ecs"
    task_definition_arn = module.task_definition.task_definition_arn
    public_subnets      = module.vpc.public_subnets
    security_group_id   = module.vpc.ecs_sg_id
    target_group_arn    = module.alb.target_group_arn
    service_name        = var.service_name
    container_name      = var.container_name
    cluster_name        = var.cluster_name 
}

module "alb" {
    source                = "./modules/alb"
    vpc_id                = module.vpc.vpc_id
    target_group_port     = var.target_group_port
    alb_security_group_id = module.vpc.alb_sg_id
    public_subnets        = module.vpc.public_subnets
    alb_name              = var.alb_name
    lb_type               = var.lb_type
}
