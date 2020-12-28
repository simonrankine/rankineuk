resource "aws_codedeploy_app" "rankineuk_app" {
  compute_platform = "Server"
  name             = "rankineuk"
}

resource "aws_codedeploy_deployment_config" "rankineuk_deployment_config" {
  deployment_config_name = "rankineuk"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 1
  }
}



resource "aws_s3_bucket" "deployment_bucket" {
  bucket = var.deployment_bucket_name
  acl    = "private"
  tags = {
    Name = "rankineuk_deployment_bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "deployment_bucket_block" {
  bucket = aws_s3_bucket.deployment_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_iam_role_policy" "deployment_bucket_policy" {
  name   = "rankineuk_deployment_bucket_policy"
  role   = aws_iam_role.rankineuk_ec2_iam_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.deployment_bucket_name}"]
    },{
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": ["arn:aws:s3:::${var.deployment_bucket_name}/*"]
    },{
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::aws-codedeploy-eu-west-1/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "code_deploy_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.rankineuk_ec2_iam_role.name
}
