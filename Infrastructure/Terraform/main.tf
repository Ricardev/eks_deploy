terraform {
  required_version = "1.4.5"


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.63.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAWKGB44BKKOZ4WJXF"
  secret_key = "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"
}

resource "aws_eks_cluster" "WeatherForecast" {
  name     = "WeatherForecast"
  role_arn = aws_iam_role.WeatherForecast-Eks-Cluster-Role.arn
  vpc_config {
    subnet_ids = [aws_subnet.Eks-Subnet-One.id, aws_subnet.Eks-Subnet-Two.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.WeatherForecast-Eks-RolePolicy-AmazonEksClusterPolicy
  ]
}

resource "aws_eks_fargate_profile" "Eks-Fargate-Profile" {
  cluster_name           = aws_eks_cluster.WeatherForecast.name
  fargate_profile_name   = "Eks-Fargate-Profile"
  pod_execution_role_arn = aws_iam_role.WeatherForecast-Eks-Cluster-Role.arn
  subnet_ids = [aws_subnet.Eks-Subnet-One.id, aws_subnet.Eks-Subnet-Two.id]
  selector {
    namespace = "Weather"
  }
}


resource "aws_ecr_repository" "WeatherForecastRepository" {
  name = "WeatherForecastRepository"
}
#------------------IAM Roles------------------#

resource "aws_iam_role" "WeatherForecast-Eks-Cluster-Role" {
  name               = "eks-role"
  assume_role_policy = data.aws_iam_policy_document.WetherForecast-Eks-RolePolicy.json
}

resource "aws_iam_role" "Eks-Pod-Role" {
  name               = "eks-pod-role"
  assume_role_policy = data.aws_iam_policy_document.WetherForecast-EksPod-RolePolicy.json
}

resource "aws_iam_role_policy_attachment" "WeatherForecast-Eks-RolePolicy-AmazonEksClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.WeatherForecast-Eks-Cluster-Role.name
}

resource "aws_iam_role_policy_attachment" "WeatherForecast-Eks-RolePolicy-AmazonEksPodPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.Eks-Pod-Role.name
}

#---------------Network---------------#
resource "aws_vpc" "Eks-Vpc" {
  cidr_block = "10.64.0.0/16"
}

resource "aws_subnet" "Eks-Subnet-One" {
  vpc_id            = aws_vpc.Eks-Vpc.id
  cidr_block        = "10.64.64.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "Eks-Subnet-Two" {
  vpc_id            = aws_vpc.Eks-Vpc.id
  cidr_block        = "10.64.65.0/24"
  availability_zone = "us-east-1b"
}




#-------------Data and Outputs-------------#

data "aws_iam_policy_document" "WetherForecast-Eks-RolePolicy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["eks.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "WetherForecast-EksPod-RolePolicy" {
  statement {
    effect = "Allow"
    principals {
      identifiers = ["eks-fargate-pods.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

output "endpoint" {
  value = aws_eks_cluster.WeatherForecast.endpoint
}