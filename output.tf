output "VPC" {
  value = aws_vpc.myVpc.arn
}

output "Internet-gateway" {
  value = aws_internet_gateway.igw.arn
}

output "Public-Subnet" {
  value = aws_subnet.public_subnet.*.arn
}

output "Private-Subnet" {
  value = aws_subnet.private_subnet.*.arn
}

output "Route-table-public" {
  value = aws_route_table.route_table_public.arn
}

output "Route-table-private" {
  value = aws_route_table.route_table_private.arn
}

output "Nat-Gateway" {
  value = aws_nat_gateway.nat-gw.id
}

output "Bastion-HOST-IP" {
  value = aws_instance.bastion.public_ip
}


output "Load-Balancer" {
  value = aws_lb.alb.arn
}
