
resource "aws_s3_bucket" "wishifai_images" {
  bucket = "wishifai-images-${var.candidate_number}"
}

resource "aws_s3_bucket_public_access_block" "wishifai_images" {
  bucket = aws_s3_bucket.wishifai_images.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
