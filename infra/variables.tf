variable "aws_region" {
  description = "AWS-region for Wshifai"
  type        = string
  default     = "eu-north-1"
}

variable "candidate_number" {
  description = "Kandidatnumber"
  type        = string
  default     = "41"
}

variable "image_tag" {
  description = "Docker-image tag fra Github Actions"
  type        = string
}