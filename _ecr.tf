locals {
  create_ecr_repository = {
    for job_key, job in var.batch_job_parameters :
    job_key => {
      "repository_name"                                  = try(job.repository_name, "${local.common_name}-batch-${job_key}")
      "repository_lifecycle_policy"                      = try(job.repository_lifecycle_policy, null)
      "repository_image_tag_mutability"                  = try(job.repository_image_tag_mutability, "MUTABLE")
      "repository_image_tag_mutability_exclusion_filter" = try(job.repository_image_tag_mutability_exclusion_filter, null)

    }
    if length(try(job.image, "")) == 0
  }
}

module "ecr" {
  source   = "terraform-aws-modules/ecr/aws"
  version  = "3.0.1"
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
  tags                                             = local.common_tags
}

output "ecr" {
  value = module.ecr
}
