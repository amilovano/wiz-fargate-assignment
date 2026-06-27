resource "aws_security_group" "mongo" {
  name        = "wiz-mongo-sg"
  description = "MongoDB security group"
  vpc_id      = module.vpc.vpc_id

  # Intentional weakness from assignment:
  # SSH publicly exposed
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Mongo reachable from Kubernetes network
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}