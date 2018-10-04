/*====
ECR repository to store our Docker images
======*/
resource "aws_ecr_repository" "openjobs_app" {
  name = "${var.repository_name}"
} 
