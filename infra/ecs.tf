data "aws_caller_identity" "current" {}

resource "aws_ecs_express_gateway_service" "wishifai" {

  service_name = "wishifai-${var.candidate_number}"

  execution_role_arn = "arn:aws:iam::244530008913:role/ecsTaskExecutionRole"

  infrastructure_role_arn = "arn:aws:iam::244530008913:role/service-role/ecsInfrastructureRoleForExpressServices"

  task_role_arn = aws_iam_role.wishifai_task_role.arn

  health_check_path = "/actuator/health"

  primary_container {
    image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/wishifai-${var.candidate_number}:${var.image_tag}"

    container_port = 8080

    environment {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.wishifai_images.bucket
    }

    environment {
    name  = "AWS_REGION"
    value = var.aws_region
    
    }
  }
}