locals {
  create_ecr_repository = {
    for job_key, job in var.batch_job_parameters :
    job_key => {
      "job_key"                                          = job_key
      "repository_name"                                  = try(job.repository_name, "${local.common_name}-batch-${job_key}")
      "repository_lifecycle_policy"                      = try(job.repository_lifecycle_policy, null)
      "repository_image_tag_mutability"                  = try(job.repository_image_tag_mutability, "MUTABLE")
      "repository_image_tag_mutability_exclusion_filter" = try(job.repository_image_tag_mutability_exclusion_filter, null)
      # Registry Scanning Configuration
      "manage_registry_scanning_configuration" = try(job.manage_registry_scanning_configuration, false)
      "registry_scan_type"                     = try(job.registry_scan_type, "ENHANCED")
      "registry_scan_rules"                    = try(job.registry_scan_rules, null)
      # Registry Replication Configuration
      "create_registry_replication_configuration" = try(job.create_registry_replication_configuration, false)
      "registry_replication_rules"                = try(job.registry_replication_rules, null)
    }
    if length(try(job.image, "")) == 0
  }
}

module "ecr" {
  source   = "terraform-aws-modules/ecr/aws"
  version  = "3.1.0"
  for_each = local.create_ecr_repository

  repository_name         = lower(each.value.repository_name)
  create_lifecycle_policy = true
  repository_lifecycle_policy = each.value.repository_lifecycle_policy != null ? each.value.repository_lifecycle_policy : jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_image_tag_mutability                  = each.value.repository_image_tag_mutability
  repository_image_tag_mutability_exclusion_filter = each.value.repository_image_tag_mutability_exclusion_filter
  repository_force_delete                          = true

  # Registry Scanning Configuration
  manage_registry_scanning_configuration = each.value.manage_registry_scanning_configuration
  registry_scan_type                     = each.value.registry_scan_type
  registry_scan_rules                    = each.value.registry_scan_rules

  # Registry Replication Configuration
  create_registry_replication_configuration = each.value.create_registry_replication_configuration
  registry_replication_rules                = each.value.registry_replication_rules

  tags = local.common_tags
}

output "ecr" {
  value = module.ecr
}
