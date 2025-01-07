resource "aws_s3_bucket" "tf_bucket" {
  bucket        = "vprofile-app-artifacts"
  force_destroy = false

  tags = {
    Name        = "vProfile bucket"
    Environment = "Dev"
  }
}