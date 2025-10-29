locals {
  batch_job_secrets_create_tmp = [
    for job_key, job in var.batch_job_parameters :
    [
      for secret_key, secret_value in try(job.map_secrets, {}) :
      {
        "${job_key}-${secret_key}" = {
          name  = secret_key
          value = secret_value
        }
      }
    ]
  ]
  batch_job_secrets_create = merge(flatten(local.batch_job_secrets_create_tmp)...)
}

module "ssm_parameter" {
  source  = "terraform-aws-modules/ssm-parameter/aws"
  version = "1.2.0"

  for_each = local.batch_job_secrets_create

  name            = can(each.value.name) ? "/batch/${local.common_name}-${each.key}" : null
  value           = try(each.value.value, null)
  values          = try(each.value.values, [])
  type            = try(each.value.type, null)
  secure_type     = try(each.value.secure_type, true)
  description     = try(each.value.description, null)
  tier            = try(each.value.tier, null)
  key_id          = try(each.value.key_id, null)
  allowed_pattern = try(each.value.allowed_pattern, null)
  data_type       = try(each.value.data_type, null)

  tags = local.common_tags
}

locals {
  batch_job_secrets = {
    for job_key, job in var.batch_job_parameters :
    job_key => [
      for secret_key, _ in try(job.map_secrets, {}) :
      {
        name      = secret_key
        valueFrom = module.ssm_parameter["${job_key}-${secret_key}"].ssm_parameter_arn
      }
    ]
  }
}


