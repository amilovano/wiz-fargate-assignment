resource "aws_security_group" "eks" {
  name   = "wiz-eks-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mongo" {
  name   = "wiz-mongo-sg"
  vpc_id = module.vpc.vpc_id

  # Intentional weakness: public SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Mongo only reachable from Kubernetes network
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_cloudtrail" "main" {
  name                          = "wiz-trail"
  s3_bucket_name                = aws_s3_bucket.mongo_backups.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}