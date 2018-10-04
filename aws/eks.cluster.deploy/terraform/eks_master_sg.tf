resource "aws_security_group" "cluster" {
  name        = "dwponica-oec-dev-eks-master-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.eks_vpc}"

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
    "Component", "sg",
    "AssignedTo", "dwponica",
    "OS", "centos",
    "Name", "dwponica-oec-dev-eks-master-sg",
    "kubernetes.io/cluster/${var.eks_cluster}", "owned",
    )
  }"
}
resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  to_port                  = 443
  type                     = "ingress"
}