# variable "nlb_arn" {
#   description = "The ARN of the network load balancer"
#   type        = string
#   validation {
#     condition     = can(regex("^arn:aws:elasticloadbalancing:([A-Za-z0-9]+(-[A-Za-z0-9]+)+):[0-9]+:loadbalancer/", var.nlb_arn))
#     error_message = "The load balancer arn must be a valid arn starting with \"^arn:aws:elasticloadbalancing:\"/net"
#   }
# }

# variable "nlb_dns" {
#   description = "The DNS name of the load balancer."
#   type        = string
#   # validation {
#   #   condition     = can(regex("^arn:aws:elasticloadbalancing:([A-Za-z0-9]+(-[A-Za-z0-9]+)+):[0-9]+:loadbalancer/", var.nlb_arn))
#   #   error_message = "The load balancer arn must be a valid arn starting with \"^arn:aws:elasticloadbalancing:\"/net"
#   # }
# }

# variable "kms_key_id" {
#   description = "The ARN for the KMS encryption key"
#   type        = string
#   validation {
#     condition     = can(regex("^arn:aws:kms:([A-Za-z0-9]+(-[A-Za-z0-9]+)+):[0-9]+:key/", var.kms_key_id))
#     error_message = "The kms key arn doesn't meet the requirement id format \"^arn:aws:kms:\""
#   }
# }

# variable "user_pool_arn" {
#   description = "The ARN for the KMS encryption key"
#   type        = string
#   validation {
#     condition     = can(regex("^arn:aws:cognito-idp:([A-Za-z0-9]+(-[A-Za-z0-9]+)+):[0-9]+:userpool/", var.user_pool_arn))
#     error_message = "The user pool arn doesn't meet the requirement id format \"^arn:aws:cognito-idp:\""
#   }
# }

# variable "acm_cert_arn" {
#   description = "The ARN of the certificate ACM"
#   type        = string
#   validation {
#     condition     = can(regex("^arn:aws:acm:([A-Za-z0-9]+(-[A-Za-z0-9]+)+):[0-9]+:certificate/", var.acm_cert_arn))
#     error_message = "The user pool arn doesn't meet the requirement id format \"^arn:aws:acm:\""
#   }
# }

# variable "domain_name" {
#   description = "Fully-qualified domain name to register"
#   type        = string
# }

# variable "lf_logs_get_invoke_arn" {
#   description = "The invoke ARN for the lambda logs get"
#   type        = string
# }

# variable "lf_events_get_invoke_arn" {
#   description = "The invoke ARN for the lambda events get"
#   type        = string
# }
