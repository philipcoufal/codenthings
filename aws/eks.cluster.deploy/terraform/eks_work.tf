resource "aws_iam_role" "node" {
  name = "${var.eks_node_role}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.node.name}"
}

resource "aws_iam_instance_profile" "node" {
  name = "dwponica-oec-dev-eks-node-prof2"
  role = "${aws_iam_role.node.name}"
}

resource "aws_security_group" "node" {
  name        = "dwponica-oec-dev-eks-node-sg"
  description = "Security group for all nodes in the cluster"

  #  vpc_id      = "${var.eks_vpc}"
  vpc_id = "${var.eks_vpc}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
    "Project", "dwponica",
    "Factory", "oec",
    "Phase", "dev",
    "Application", "eks",
    "Component", "accessmgmt",
    "AssignedTo", "dwponica",
    "OS", "centos",
    "Name", "dwponica-oec-dev-eks-node-sg",
    "kubernetes.io/cluster/${var.eks_cluster}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  tags = "${
    map(
    "Project", "dwponica",
    "Factory", "oec",
    "Phase", "dev",
    "Application", "eks",
    "Component", "worker",
    "AssignedTo", "dwponica",
    "OS", "centos",
    "Name", "dwponica-oec-dev-eks-node-sg",
    "kubernetes.io/cluster/${var.eks_cluster}", "owned",
    )
  }"

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${var.eks_cluster}
USERDATA
}

resource "aws_launch_configuration" "eks" {
  associate_public_ip_address = "true"
  iam_instance_profile        = "${aws_iam_instance_profile.node.name}"
  image_id                    = "ami-0440e4f6b9713faf6"
  instance_type               = "m4.large"
  name_prefix                 = "dwponica-oec-dev-eks-lc"
  security_groups             = ["${aws_security_group.node.id}"]
  user_data_base64            = "${base64encode(local.node-userdata)}"
  key_name                    = "dwponica-oec-prod"
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.eks.id}"
  max_size             = 2
  min_size             = 1
  name                 = "dwponica-oec-dev-eks-asg"

  #  vpc_zone_identifier  = ["${aws_subnet.*.id}"]
  vpc_zone_identifier = ["${var.public_subnet_ids}"]
  
  tag {
    key                 = "Name"
    value               = "dwponica-oec-dev-eks-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster}"
    value               = "owned"
    propagate_at_launch = true
  }

}
