# ec2.tf

# ── IAM: overly permissive role (intentional weakness) ──────────────────────
resource "aws_iam_role" "mongo_vm" {
  name = "wiz-mongo-vm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Intentional weakness: EC2 full access (can create VMs)
resource "aws_iam_role_policy_attachment" "mongo_vm_ec2_full" {
  role       = aws_iam_role.mongo_vm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Needed for backup script to write to S3
resource "aws_iam_role_policy_attachment" "mongo_vm_s3_full" {
  role       = aws_iam_role.mongo_vm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "mongo_vm" {
  name = "wiz-mongo-vm-profile"
  role = aws_iam_role.mongo_vm.name
}

# ── Security Group: SSH open to internet (intentional weakness) ──────────────
resource "aws_security_group" "mongo_vm" {
  name        = "wiz-mongo-vm-sg"
  description = "Mongo VM - intentional weaknesses for Wiz exercise"
  vpc_id      = module.vpc.vpc_id

  # Intentional weakness: SSH open to world
  ingress {
    description = "SSH from anywhere (intentional weakness)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB access from EKS private subnets only
  ingress {
    description = "MongoDB from EKS private subnets"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "wiz-mongo-vm-sg" }
}

# ── SSH Key Pair ─────────────────────────────────────────────────────────────
resource "aws_key_pair" "mongo_vm" {
  key_name   = "wiz-mongo-vm-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# ── EC2 Instance ─────────────────────────────────────────────────────────────
# Ubuntu 20.04 LTS (outdated - intentional weakness)
data "aws_ami" "ubuntu_2004" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "mongo_vm" {
  ami                         = data.aws_ami.ubuntu_2004.id
  instance_type               = "t3.medium"
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.mongo_vm.id]
  iam_instance_profile        = aws_iam_instance_profile.mongo_vm.name
  key_name                    = aws_key_pair.mongo_vm.key_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/scripts/mongo-setup.sh", {
    bucket_name = aws_s3_bucket.mongo_backups.bucket
  })

  tags = { Name = "wiz-mongo-vm" }
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "mongo_vm_public_ip" {
  description = "Public IP of the MongoDB VM"
  value       = aws_instance.mongo_vm.public_ip
}

output "mongo_vm_private_ip" {
  description = "Private IP (used by EKS to connect to MongoDB)"
  value       = aws_instance.mongo_vm.private_ip
}