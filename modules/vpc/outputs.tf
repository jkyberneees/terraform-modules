output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = join(",", aws_subnet.this.*.id)
}