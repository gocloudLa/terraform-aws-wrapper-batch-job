module "wrapper_batch_job" {

  source = "../../"

  /*----------------------------------------------------------------------*/
  /* General Variables                                                    */
  /*----------------------------------------------------------------------*/

  metadata = local.metadata

  /*----------------------------------------------------------------------*/
  /* Batch Parameters                                                     */
  /*----------------------------------------------------------------------*/

  batch_job_parameters = {
    "ExSimple" = {

      command = ["ls", "-la"]
      # memory                   = "2048"
      # vcpu                     = "1"
      #cloudwatch_log_group_retention_in_days = 14
      #assignPublicIp = "ENABLED" # subnet public

      # Policies que usan la tasks desde el codigo desarrollado
      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]

      # Policies que usa el servicio para poder iniciar tasks (ecr / ssm / etc)
      task_exec_iam_role_policies = {}
      task_exec_iam_statements    = {}

      map_environment = {
        "ENV_1" = "env_value_1"
        "ENV_2" = "env_value_2"
      }
      map_secrets = {
        "SECRET_ENV_1" = "secret_env_value_1"
        "SECRET_ENV_2" = "secret_env_value_2"
      }
    },
    "ExPublicEcr" = {

      command = ["ls", "-la"]
      image   = "public.ecr.aws/runecast/busybox:1.33.1"
      # memory                   = "2048"
      # vcpu                     = "1"
      #cloudwatch_log_group_retention_in_days = 14

      # Policies que usan la tasks desde el codigo desarrollado
      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]

      # Policies que usa el servicio para poder iniciar tasks (ecr / ssm / etc)
      task_exec_iam_role_policies = {}
      task_exec_iam_statements    = {}

      map_environment = {
        "ENV_1" = "env_value_1"
        "ENV_2" = "env_value_2"
      }
      map_secrets = {
        "SECRET_ENV_1" = "secret_env_value_1"
        "SECRET_ENV_2" = "secret_env_value_2"
      }
    },
    "ExRetry" = {

      command = ["ls", "-la"]
      # image   = "public.ecr.aws/runecast/busybox:1.33.1"
      memory                                 = "2048"
      vcpu                                   = "1"
      cloudwatch_log_group_retention_in_days = 14

      #Policies que usan la tasks desde el codigo desarrollado
      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]

      #Policies que usa el servicio para poder iniciar tasks (ecr / ssm / etc)
      task_exec_iam_role_policies = {}
      task_exec_iam_statements    = {}

      map_environment = {
        "ENV_1" = "env_value_1"
        "ENV_2" = "env_value_2"
      }
      map_secrets = {
        "SECRET_ENV_1" = "secret_env_value_1"
        "SECRET_ENV_2" = "secret_env_value_2"
      }

      attempt_duration_seconds = 60
      retry_strategy = {
        attempts = 3
        evaluate_on_exit = {
          retry_error = {
            action       = "RETRY"
            on_exit_code = 1
          }
          exit_success = {
            action       = "EXIT"
            on_exit_code = 0
          }
        }
      }
    }
  }

  batch_job_defaults = var.batch_job_defaults
}
