resource "aws_s3_bucket" "static_bucket" {
bucket = "zirong-sctp-sandbox"
force_destroy = true
}
resource "aws_s3_bucket_public_access_block" "enable_public_access" { 
bucket= aws_s3_bucket.static_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  }
resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.static_bucket.arn}/*",
        Principal = "*"
      }
    ]
  })
}
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

data "aws_route53_zone" "sctp_zone" {
name = "sctp-sandbox.com"
}
resource "aws_route53_record" "www" {
zone_id = data.aws_route53_zone.sctp_zone.zone_id
name = "zirong" # Bucket prefix before sctp-sandbox.com
type = "A"
alias {
name = aws_s3_bucket_website_configuration.website.website_domain
zone_id = aws_s3_bucket.static_bucket.hosted_zone_id
evaluate_target_health = true
}
}