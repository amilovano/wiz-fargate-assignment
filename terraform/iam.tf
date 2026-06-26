resource "aws_iam_role" "mongo_vm_role" {
  name = "wiz-mongo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Intentional weakness
resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.mongo_vm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "mongo_profile" {
  role = aws_iam_role.mongo_vm_role.name
}