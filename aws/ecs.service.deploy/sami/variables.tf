########################### AWS Credentials###########################
variable "aws_access_key_id" {
  description = "AWS access key"
}
variable "aws_secret_access_key" {
  description = "AWS secret access key"
}
variable "ecs_cluster" {
  description = "ECS cluster name"
}
variable "ecs_key_pair_name" {
  description = "ECS key pair name"
}
variable "region" {
  description = "AWS region"
}
variable "availability_zone" {
  description = "availability zone"
  default = {
    us-east-1 = "us-east-1"
  }
}
########################### VPC Config ###############################
variable "ecs_vpc" {
  description = "VPC for ECS Cluster"
}
variable "ecs_subnet_01" {
  description = "subnet 1 for ecs cluster"
}
variable "ecs_subnet_02" {
  description = "subnet 2 for ecs cluster"
}
########################### Autoscaling Config #######################
variable "max_instance_size" {
  description = "Maximum number of instances in the cluster"
}
variable "min_instance_size" {
  description = "Minimum number of instances in the cluster"
}
variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
}
########################### Lanuch Config #######################
variable "health_check_type" {
  description = "Desired number of instances in the cluster"
}
variable "image_id" {
  description = "Desired number of instances in the cluster"
}
variable "volume_type" {
  description = "Desired number of instances in the cluster"
}
variable "volume_size" {
  description = "Desired number of instances in the cluster"
}
variable "instance_type" {
  description = "Desired number of instances in the cluster"
}
variable "delete_on_termination" {
  description = "Desired number of instances in the cluster"
}
########################### Service Config #######################
variable "production_database_username" {
  description = "The username for the Production database"
}

variable "production_database_password" {
  description = "The user password for the Production database"
}

variable "production_secret_key_base" {
  description = "The Rails secret key for production"
}

variable "domain" {
  default = "The domain of your application"
}
variable "app_name" {
  description = "The environment"
}

variable "availability_zones" {
  type        = "list"
  description = "The azs to use"
}

variable "security_groups_ids" {
  type        = "list"
  description = "The SGs to use"
}

variable "subnets_ids" {
  type        = "list"
  description = "The private subnets to use"
}

variable "public_subnet_ids" {
  type        = "list"
  description = "The private subnets to use"
}

variable "database_endpoint" {
  description = "The database endpoint"
}

variable "database_username" {
  description = "The database username"
}

variable "database_password" {
  description = "The database password"
}

variable "database_name" {
  description = "The database that the app will use"
}

variable "repository_name" {
  description = "The name of the repisitory"
}

variable "secret_key_base" {
  description = "The secret key base to use in the app"
}
