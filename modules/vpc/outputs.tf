output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = join(",", aws_subnet.this.*.id)
}

output "default_route_table_id" {
  value = aws_vpc.this.*.default_route_table_id[0]
}