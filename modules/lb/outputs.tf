output "alb_sg_id" {
  value = aws_security_group.this.id
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.this.*.arn[0]

  depends_on = [
    aws_lb.this
  ]
}

output "alb_address" {
  value = aws_lb.this.dns_name
}