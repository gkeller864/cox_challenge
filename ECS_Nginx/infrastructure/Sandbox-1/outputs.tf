output "alb_nginx" {
  value       = module.alb_nginx.dns_alb
  description = "Output used for Route53 to associate ALB"
}
