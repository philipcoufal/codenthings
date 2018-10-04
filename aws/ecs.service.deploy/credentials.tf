provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  assume_role{
  role_arn    = "arn:aws:iam::801842999866:role/DF18Admin"}
	region      = "${var.region}"
	}