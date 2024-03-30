#---------------------------------------------
# vpc
#---------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-vpc"
  }
}


#---------------------------------------------
# public subnet
#---------------------------------------------
resource "aws_subnet" "public" {
  count                   = 2
  availability_zone       = var.availability_zones[count.index]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-public-${var.zones[count.index]}"
  }
}


#---------------------------------------------
# private subnet
#---------------------------------------------
# resource "aws_subnet" "private" {
#   count                   = 2
#   availability_zone       = var.availability_zones[count.index]
#   vpc_id                  = aws_vpc.vpc.id
#   cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 2)
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-private-${var.zones[count.index]}"
#   }
# }


#---------------------------------------------
# public route table
#---------------------------------------------
resource "aws_route_table" "public_route_table" {
  count  = 2
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-public_rt-${var.zones[count.index]}"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count          = 2
  route_table_id = aws_route_table.public_route_table[count.index].id
  subnet_id      = aws_subnet.public[count.index].id
}


#---------------------------------------------
# private route table
#---------------------------------------------
# resource "aws_route_table" "private_route_table" {
#   count  = 2
#   vpc_id = aws_vpc.vpc.id

#   tags = {
#     Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-private_rt-${var.zones[count.index]}"
#   }
# }

# resource "aws_route_table_association" "private_rt_association" {
#   count          = 2
#   route_table_id = aws_route_table.private_route_table[count.index].id
#   subnet_id      = aws_subnet.private[count.index].id
# }



#---------------------------------------------
# internet gatway
#---------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-igw"
  }
}

resource "aws_route" "igw_route" {
  count                  = 2
  route_table_id         = aws_route_table.public_route_table[count.index].id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}


# #---------------------------------------------
# # Elastic IP fo NatGatway
# #---------------------------------------------
# resource "aws_eip" "for_nat_gateway" {
#   count = 2
#   vpc   = true
#   depends_on = [
#     aws_internet_gateway.igw
#   ]

#   tags = {
#     Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-nat-eip-${var.zones[count.index]}"
#   }
# }


# #---------------------------------------------
# # NatGatway
# #---------------------------------------------
# resource "aws_nat_gateway" "nat_gateway" {
#   count         = 2
#   allocation_id = aws_eip.for_nat_gateway[count.index].id # Elastic IPアドレスの関連付け
#   subnet_id     = aws_subnet.public[count.index].id       # NATゲートウェイの設置位置はパブリックサブネット
#   depends_on = [
#     aws_internet_gateway.igw
#   ]

#   tags = {
#     Name = "${var.project_name.test_ecs["tentative"]}-${var.project_name.test_ecs["service_name"]}-nat-${var.zones[count.index]}"
#   }
# }

# resource "aws_route" "ngw_route" {
#   count                  = length(var.availability_zones)
#   route_table_id         = aws_route_table.private_route_table[count.index].id
#   nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
#   destination_cidr_block = "0.0.0.0/0"
# }

