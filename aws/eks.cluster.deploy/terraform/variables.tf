########################### AWS Credentials###########################
/* variable "aws_access_key_id" {
  description = "AWS access key"
}
variable "aws_secret_access_key" {
  description = "AWS secret access key"
}
*/
variable "eks_cluster" {
  description = "eks cluster name"
}
variable "eks_key_pair_name" {
  description = "eks key pair name"
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
variable "eks_public_sg" {
  description = "default vpc security group"
  }
########################### VPC Config ###############################
variable "eks_vpc" {
  description = "VPC for eks Cluster"
}
variable "eks_subnet_01" {
  description = "subnet 1 for eks cluster"
}
variable "eks_subnet_02" {
  description = "subnet 2 for eks cluster"
}
variable "eks_load_balancer" {
  description = "eks load balancer name"
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
########################## Task Definition ################################
variable "eks_td_family" {
  description = "eks task definition family"
}
########################### Service Role ###################################
variable "eks_service_role" {
  description = "eks service role name"
}
variable "eks_sr_path" {
  description = "eks service role path"
}
variable "eks_sr_policy_name" {
  description = "eks service role policy name"
}
variable "eks_sr_policy_path" {
  description = "eks service role policy path"
}
variable "eks_sr_description" {
  description = "eks service role policy description"
}
variable "eks_node_role" {
  description = "eks node role name"
}
############################# eks ALB #################################
variable "eks_target_group" {
  description = "eks target group"
}
variable "eks_alb_port" {
  description = "eks alb port"
}
variable "eks_alb_protocol" {
  description = "eks alb networking protocol"
}
variable "eks_alb_healthy_threshold" {
  description = "Healty threshhold"
}
variable "eks_alb_unhealthy_threshold" {
  description = "Unhealty threshhold"
}
variable "eks_alb_interval" {
  description = "ALB Interval"
}
variable "eks_alb_matcher" {
  description = "ALB Matcher"
}
variable "eks_alb_path" {
  description = "ALB path"
}
variable "eks_alb_port_mode" {
  description = "ALB port mode"
}
variable "eks_alb_protocol_hc" {
  description = "ALB Protocol for healthcheck"
}
variable "eks_alb_timeout" {
  description = "ALB healthcheck timeout"
}
variable "eks_alb_listener_port" {
  description = "ALB listener port"
}
variable "eks_alb_listener_protocol" {
  description = "ALB listener protocol"
}
variable "eks_alb_listener_type" {
  description = "ALB listener type"
}
########################## eks ASG #################################
variable "max_capacity" {
  description = "ASG maximum capacity"
}
variable "min_capacity" {
  description = "ASG minimum capacity"
}
variable "scalable_dimension" {
  description = "ASG scalable dimension"
}
variable "service_namespace" {
  description = "ASG service namespace"
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
variable "desired_count" {
  description = "eks service count"
}
variable "container_port" {
  description = "eks container port"
}
variable "container_name" {
  description = "eks container name"
}