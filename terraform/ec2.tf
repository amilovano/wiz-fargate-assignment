resource "aws_instance" "mongo_vm" {

  ami           = "ami-0fc5d935ebf8bc3bc"
  instance_type = "t3.micro"

  subnet_id = module.vpc.public_subnets[0]

  vpc_security_group_ids = [
    aws_security_group.mongo.id
  ]

  iam_instance_profile = aws_iam_instance_profile.mongo_profile.name

  tags = {
    Name = "wiz-mongodb"
  }
}