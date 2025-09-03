resource "aws_batch_job_definition" "this" {
  name = var.name
  type = "container"

  platform_capabilities = ["FARGATE"]
  container_properties = jsonencode({
    command                      = var.command
    environment                  = var.environment
    executionRoleArn             = aws_iam_role.task_exec.arn
    fargatePlatformConfiguration = var.fargate_platform_configuration
    image                        = var.image
    jobRoleArn                   = aws_iam_role.tasks.arn
    linuxParameters              = var.linux_parameters
    logConfiguration             = var.log_configuration
    mountPoints                  = var.mount_points
    networkConfiguration = {
      "assignPublicIp" = var.assignPublicIp
    }
    privileged             = var.privileged
    readonlyRootFilesystem = var.readonly_root_filesystem
    resourceRequirements = [
      {
        type  = "VCPU",
        value = var.vcpu
      },
      {
        type  = "MEMORY",
        value = var.memory
      }
    ]
    runtimePlatform = var.runtime_platform
    secrets         = var.secrets
    ulimits         = var.ulimits
    user            = var.user
    volumes         = var.volumes
  })
  dynamic "retry_strategy" {
    for_each = var.retry_strategy != null ? [var.retry_strategy] : []
    content {
      attempts = lookup(retry_strategy.value, "attempts", 1)

      dynamic "evaluate_on_exit" {
        for_each = try(retry_strategy.value.evaluate_on_exit, {})
        content {
          action       = evaluate_on_exit.value.action
          on_exit_code = lookup(evaluate_on_exit.value, "on_exit_code", null)
        }
      }
    }
  }

  dynamic "timeout" {
    for_each = var.attempt_duration_seconds != null ? [var.attempt_duration_seconds] : []
    content {
      attempt_duration_seconds = timeout.value
    }
  }

  tags = var.tags
}
