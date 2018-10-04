/*====
ECS task definitions
======*/

/* the task definition for the web service */
data "template_file" "web_task" {
    template = "${file("${path.module}/tasks/task_definition.json")}"

  vars {
    image           = "${aws_ecr_repository.openjobs_app.repository_url}"
    secret_key_base = "${var.secret_key_base}"
    database_url    = "postgresql://${var.database_username}:${var.database_password}@${var.database_endpoint}:5432/${var.database_name}?encoding=utf8&pool=40"
    log_group       = "testsets"
  }
}
data "aws_ecs_task_definition" "web" {
depends_on = ["aws_ecs_task_definition.web"]
}
resource "aws_ecs_task_definition" "web" {
  family                   = "${var.app_name}_web"
  container_definitions    = "${data.template_file.web_task.rendered}"
  requires_compatibilities = ["ec2"]
  cpu                      = "256"
  memory                   = "512"
/*  execution_role_arn       = "${aws_iam_role.ecs-service-role.arn}" */
/*  task_role_arn            = "${aws_iam_role.ecs-service-role.arn}" */
}