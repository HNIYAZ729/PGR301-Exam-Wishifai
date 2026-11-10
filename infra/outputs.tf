output "wishifai_url" {
  description = "Public URL for Wishifai"
  value       = aws_ecs_express_gateway_service.wishifai.ingress_paths[0].endpoint
}
