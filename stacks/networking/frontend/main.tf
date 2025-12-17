/*
* # Stack: Frontend (S3 + CloudFront + WAF + ACM)
*/

module "frontend_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = local.workspace.frontend.bucket_name

  force_destroy = local.workspace.frontend.force_destroy

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.workspace.tags
}

# CloudFront (simplificado). Si ya tienes módulo interno, aquí se puede reemplazar.
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = local.workspace.frontend.cf_comment
  default_root_object = "index.html"

  origin {
    domain_name = module.frontend_bucket.s3_bucket_bucket_regional_domain_name
    origin_id   = "s3-frontend"
  }

  default_cache_behavior {
    target_origin_id       = "s3-frontend"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    compress         = true
  }

  viewer_certificate {
    acm_certificate_arn      = local.workspace.frontend.acm_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = local.workspace.frontend.waf_web_acl_id

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.workspace.tags
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.10.0"

  name               = local.workspace.alb.name
  load_balancer_type = "application"
  vpc_id             = local.workspace.alb.vpc_id
  subnets            = local.workspace.alb.public_subnet_ids

  security_groups = local.workspace.alb.security_group_ids

  listeners = {
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = local.workspace.alb.certificate_arn

      forward = {
        target_group_key = "tg_api"
      }
    }
  }

  target_groups = {
    tg_api = {
      name_prefix      = "api-"
      protocol         = "HTTP"
      port             = local.workspace.alb.target_port
      target_type      = "ip"
      health_check = {
        enabled             = true
        path                = local.workspace.alb.healthcheck_path
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 3
      }
    }
  }

  tags = local.workspace.tags
}