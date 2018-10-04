resource "aws_ecr_repository" "openjobs_app" {
  name = "${var.repository_name}"
} 