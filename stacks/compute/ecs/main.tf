/*
* # Stack: ECS Fargate (API)
* - terraform-aws-modules/ecs/aws
*/

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.11.4"

  cluster_name = local.workspace.ecs.cluster_name

  services = {
    api = {
      cpu    = local.workspace.ecs.cpu
      memory = local.workspace.ecs.memory

      desired_count = local.workspace.ecs.desired_count
      launch_type   = "FARGATE"

      subnet_ids         = local.workspace.ecs.private_subnet_ids
      security_group_ids = local.workspace.ecs.security_group_ids

      load_balancer = {
        service = {
          target_group_arn = local.workspace.ecs.target_group_arn
          container_name   = "api"
          container_port   = local.workspace.ecs.container_port
        }
      }

      container_definitions = {
        api = {
          image = local.workspace.ecs.image
          port_mappings = [
            { containerPort = local.workspace.ecs.container_port, protocol = "tcp" }
          ]
          environment = local.workspace.ecs.environment
          secrets     = local.workspace.ecs.secrets
          log_configuration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = local.workspace.ecs.log_group
              awslogs-region        = var.region
              awslogs-stream-prefix = "api"
            }
          }
        }
      }
    }
  }

  tags = local.workspace.tags
}
