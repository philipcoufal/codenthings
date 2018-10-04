resource "aws_security_group" "ecs_service" {
  vpc_id      = "${var.ecs_vpc}"
  name        = "${var.app_name}-ecs-service-sg"
  description = "Allow egress from container"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.app_name}-ecs-service-sg"
    Environment = "${var.app_name}"
  }
}

resource "aws_ecs_service" "test-ecs-service" {
  	name            = "test-ecs-service"
	iam_role        = "${aws_iam_role.ecs-service-role.name}"
  	cluster         = "${var.ecs_cluster}"
  	task_definition = "${aws_ecs_task_definition.microsoftiis.family}:${max("${aws_ecs_task_definition.microsoftiis.revision}", "${data.aws_ecs_task_definition.microsoftiis.revision}")}"
  	desired_count   = 2
 	
	load_balancer {
    	target_group_arn  = "${aws_alb_target_group.ecs-target-group.arn}"
    	container_port    = 80
    	container_name    = "microsoftiis"
	}
/*##### dependent on awsvpc for the networking mode	#####
	network_configuration {
		security_groups = ["${aws_security_group.ecs_service.id}"]
		subnets         = ["${var.subnets_ids}"]
  	}
*/
}