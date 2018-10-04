terraform {
  required_version = "= 0.11.8"
  backend "s3" {
    bucket               = "halliburton-terraform-state"
    key                  = "terraform/aws/dwponica-oec-dev-eks.tfstate"
    workspace_key_prefix = "PREFIX_PLACEHOLDER"
    region               = "us-east-1"
  }
}
