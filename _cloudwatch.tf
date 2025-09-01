resource "aws_cloudwatch_log_group" "this" {
  for_each = var.batch_job_parameters

  name              = "/aws/batch/${local.common_name}-${each.key}"
  retention_in_days = try(var.batch_job_parameters.cloudwatch_log_group_retention_in_days, 14)
  kms_key_id        = try(var.batch_job_parameters.cloudwatch_log_group_kms_key_id, null)

  tags = local.common_tags
}

locals {
  log_configuration = {
    for job_key, job in var.batch_job_parameters : job_key => {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this[job_key].name
        awslogs-region        = data.aws_region.current.region
        awslogs-stream-prefix = "${local.common_name}-${job_key}"
      }
      secretOptions = []
    }
  }
}

