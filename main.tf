provider "aws" {
    region = "ap-southeast-1"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/18"

    tags = {
        Name = "Main VPC"
    }
}

resource "aws_subnet" "public"{
    vpc_id      =   aws_vpc.main.id
    cidr_block  =   "10.0.0.0/24"

    tags = {
        Name = "Public Subnet"
    }
}

resource "aws_subnet" "private" {
    vpc_id      =   aws_vpc.main.id
    cidr_block  =   "10.0.1.0/24"

    tags    = {
        Name    = "Private Subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id      =   aws_vpc.main.id

    tags = {
        Name = "Main IGW"
    }
}

resource "aws_eip" "nat_eip" {
    vpc         = true
    depends_on  = [aws_internet_gateway.igw]
    tags = {
      Name = "NAT Gateway EIP"
    }
}

resource "aws_nat_gateway" "nat"{
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public.id

    tags = {
      Name = "Main Nat Gateway"
    }
}

resource "aws_route_table" "public" {
    vpc_id          = aws_vpc.main.id

    route {
        cidr_block  =   "0.0.0.0/0"
        gateway_id  =   aws_internet_gateway.igw.id
    }
    tags = {
      Name = "Public Route Table"
    }
}

resource "aws_route_table_association"  "public"{
    subnet_id       =   aws_subnet.public.id
    route_table_id  =   aws_route_table.public.id
}


# terraform {
#     backend "s3" {
#       bucket =  "terraform-state-staging"
#       key    =  "eks/terraform.tfstate"
#       region = "ap-southeast-1"
#     }
# }

# data "aws_eks_cluster" "cluster" {
#     name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#     name = module.eks.cluster_id
# }

# provider "kubernetes" {
#     hostname                = "data.aws_eks_cluster.cluster.endpoint"
#     cluster_ca_certificate  = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#     token                   = data.aws_eks_cluster_auth_cluster.token
#     load_config_file        = false
#     version                 = "~> 1.9s"
# }

# module "eks" {
#   source          = "terraform-aws-modules/eks/aws"
#   cluster_name    = "my-eks"
#   cluster_version = "1.17"
#   subnets         = ["subnet-06acb22f7edfdd754", "subnet-009974158ec3d4870"]
#   vpc_id          = "vpc-0d8c98ba97abbcb29"

#   node_groups = {
#     public = {
#       subnets          = ["subnet-06acb22f7edfdd754"]
#       desired_capacity = 1
#       max_capacity     = 10
#       min_capacity     = 1

#       instance_type = "t2.small"
#       k8s_labels = {
#         Environment = "public"
#       }
#     }
#     private = {
#       subnets          = ["subnet-009974158ec3d4870"]
#       desired_capacity = 1
#       max_capacity     = 10
#       min_capacity     = 1

#       instance_type = "t2.small"
#       k8s_labels = {
#         Environment = "private"
#       }
#     }
#   }

# }