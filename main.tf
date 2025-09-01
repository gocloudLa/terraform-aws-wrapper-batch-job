module "batch_job" {
  source = "./modules/aws/terraform-aws-batch"

  for_each = var.batch_job_parameters

  name                                    = "${local.common_name}-${each.key}"
  attempt_duration_seconds                = try(each.value.attempt_duration_seconds, var.batch_job_defaults.attempt_duration_seconds, null)
  assignPublicIp                          = try(each.value.assignPublicIp, var.batch_job_defaults.assignPublicIp, "DISABLED")
  command                                 = try(each.value.command, var.batch_job_defaults.command, [])
  environment                             = local.batch_job_environments[each.key]
  image                                   = try(each.value.image, module.ecr[each.key].repository_url)
  log_configuration                       = local.log_configuration[each.key]
  memory                                  = try(each.value.memory, var.batch_job_defaults.memory, "2048")
  mount_points                            = try(each.value.mount_points, var.batch_job_defaults.mount_points, [])
  vcpu                                    = try(each.value.vcpu, var.batch_job_defaults.vcpu, "1")
  readonly_root_filesystem                = try(each.value.readonly_root_filesystem, var.batch_job_parameters.readonly_root_filesystem, false)
  retry_strategy                          = try(each.value.retry_strategy, var.batch_job_defaults.retry_strategy, {})
  fargate_platform_configuration          = try(each.value.fargate_platform_configuration, var.batch_job_parameters.fargate_platform_configuration, { platformVersion = "LATEST" })
  secrets                                 = local.batch_job_secrets[each.key]
  task_exec_iam_role_arn                  = try(each.value.task_exec_iam_role_arn, var.batch_job_defaults.task_exec_iam_role_arn, null)
  task_exec_iam_role_description          = try(each.value.task_exec_iam_role_description, var.batch_job_defaults.task_exec_iam_role_description, null)
  task_exec_iam_role_max_session_duration = try(each.value.task_exec_iam_role_max_session_duration, var.batch_job_defaults.task_exec_iam_role_max_session_duration, null)
  task_exec_iam_role_name                 = try(each.value.task_exec_iam_role_name, var.batch_job_defaults.task_exec_iam_role_name, null)
  task_exec_iam_role_path                 = try(each.value.task_exec_iam_role_path, var.batch_job_defaults.task_exec_iam_role_path, null)
  task_exec_iam_role_permissions_boundary = try(each.value.task_exec_iam_role_permissions_boundary, var.batch_job_defaults.task_exec_iam_role_permissions_boundary, null)
  task_exec_iam_role_policies             = try(each.value.task_exec_iam_role_policies, var.batch_job_defaults.task_exec_iam_role_policies, {})
  task_exec_iam_role_tags                 = try(each.value.task_exec_iam_role_tags, var.batch_job_defaults.task_exec_iam_role_tags, {})
  task_exec_iam_role_use_name_prefix      = try(each.value.task_exec_iam_role_use_name_prefix, var.batch_job_defaults.task_exec_iam_role_use_name_prefix, true)
  task_exec_iam_statements                = try(each.value.task_exec_iam_statements, var.batch_job_defaults.task_exec_iam_statements, {})
  task_exec_secret_arns                   = try(each.value.task_exec_secret_arns, var.batch_job_defaults.task_exec_secret_arns, ["arn:aws:secretsmanager:*:*:secret:${local.common_name}-${each.key}-*"])
  task_exec_ssm_param_arns                = try(each.value.task_exec_ssm_param_arns, var.batch_job_defaults.task_exec_ssm_param_arns, ["arn:aws:ssm:*:*:parameter/batch/${local.common_name}-${each.key}-*"])
  task_tags                               = try(each.value.task_tags, var.batch_job_defaults.task_tags, {})
  tasks_iam_role_arn                      = try(each.value.tasks_iam_role_arn, var.batch_job_defaults.tasks_iam_role_arn, null)
  tasks_iam_role_description              = try(each.value.tasks_iam_role_description, var.batch_job_defaults.tasks_iam_role_description, null)
  tasks_iam_role_name                     = try(each.value.tasks_iam_role_name, var.batch_job_defaults.tasks_iam_role_name, null)
  tasks_iam_role_path                     = try(each.value.tasks_iam_role_path, var.batch_job_defaults.tasks_iam_role_path, null)
  tasks_iam_role_permissions_boundary     = try(each.value.tasks_iam_role_permissions_boundary, var.batch_job_defaults.tasks_iam_role_permissions_boundary, null)
  tasks_iam_role_policies                 = try(each.value.tasks_iam_role_policies, var.batch_job_defaults.tasks_iam_role_policies, {})
  tasks_iam_role_statements               = try(each.value.tasks_iam_role_statements, var.batch_job_defaults.tasks_iam_role_statements, {})
  tasks_iam_role_tags                     = try(each.value.tasks_iam_role_tags, var.batch_job_defaults.tasks_iam_role_tags, {})
  tasks_iam_role_use_name_prefix          = try(each.value.tasks_iam_role_use_name_prefix, var.batch_job_defaults.tasks_iam_role_use_name_prefix, true)


  tags = merge(local.common_tags, { workload = "${each.key}" })
}