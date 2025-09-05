# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform AWS Batch Job Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-batch-job/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-batch-job.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-batch-job.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-batch-job/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The AWS Batch_job Terraform Wrapper defines the configuration of the container properties for the job definition.

### ✨ Features

- 📦 [Public ECR Container](#public-ecr-container) - Run containers from public ECR images with custom environment and secrets

- 🔁 [Retry Strategy](#retry-strategy) - Configure retries and exit evaluation for container tasks



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-ecr" target="_blank">terraform-aws-modules/ecr/aws</a> | 2.4.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-ssm-parameter" target="_blank">terraform-aws-modules/ssm-parameter/aws</a> | 1.1.2 |



## 🚀 Quick Start
```hcl
"ExSimple" = {

      command = ["ls", "-la"]
      # memory                   = "2048"
      # vcpu                     = "1"

      # Policies used by the tasks from the developed code
      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]

      # Policies used by the service to be able to start tasks (ecr / ssm / etc)
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
    }

  batch_job_defaults = var.batch_job_defaults
```


## 🔧 Additional Features Usage

### Public ECR Container
This example shows how to run a container from a **public ECR image**.<br/>
It defines environment variables, secrets, and attaches IAM policies for the task role.<br/>
Useful for quick testing or running tools like BusyBox without a private registry.


<details><summary>Configuration Code</summary>

```hcl
ecs_service_parameters = {
  ExPublicEcr = {
    command = ["ls", "-la"]
    image   = "public.ecr.aws/runecast/busybox:1.33.1"
    # memory                   = "2048"
    # vcpu                     = "1"
    # cloudwatch_log_group_retention_in_days = 14

    tasks_iam_role_policies = {
      ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    }
    tasks_iam_role_statements = [
      {
        actions   = ["s3:List*"]
        resources = ["arn:aws:s3:::*"]
      }
    ]

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
  }
}
```


</details>


### Retry Strategy
This example shows how to configure a container with **retry strategies**.<br/>
It specifies memory/CPU, CloudWatch logs retention, environment variables, and IAM policies.<br/>
Additionally, it defines `attempt_duration_seconds` and a `retry_strategy` with exit code evaluation.


<details><summary>Configuration Code</summary>

```hcl
ecs_service_parameters = {
  ExRetry = {
    command = ["ls", "-la"]
    # image   = "public.ecr.aws/runecast/busybox:1.33.1"
    memory                                 = "2048"
    vcpu                                   = "1"
    cloudwatch_log_group_retention_in_days = 14

    tasks_iam_role_policies = {
      ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    }
    tasks_iam_role_statements = [
      {
        actions   = ["s3:List*"]
        resources = ["arn:aws:s3:::*"]
      }
    ]

    task_exec_iam_role_policies = {}
    task_exec_iam_role_statements = {}

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
```


</details>




## 📑 Inputs
| Name                                    | Description                                                                  | Type           | Default                                                                    | Required |
| --------------------------------------- | ---------------------------------------------------------------------------- | -------------- | -------------------------------------------------------------------------- | -------- |
| name                                    | Job name                                                                     | `string`       | `${local.common_name}-${each.key}`                                         | no       |
| command                                 | List of commands that run when the container starts                          | `list(string)` | `[]`                                                                       | no       |
| environment                             | List of environment variables to be passed to the container during execution | `list(object)` | `""`                                                                       | no       |
| image                                   | URI of the container image to be used for running the task                   | `string`       | `""`                                                                       | no       |
| log_configuration                       | Configuration for container log registration                                 | `any`          | `{}`                                                                       | no       |
| memory                                  | Amount of memory to be assigned to the container during execution            | `string`       | `"2048"`                                                                   | no       |
| mount_points                            | List of mount points for volumes in the container                            | `list(any)`    | `{}`                                                                       | no       |
| vcpu                                    | Number of vCPUs assigned to the container                                    | `string`       | `"1"`                                                                      | no       |
| readonly_root_filesystem                | Determines if the container's root file system should be read-only           | `bool`         | `false`                                                                    | no       |
| fargate_platform_configuration          | AWS Fargate platform configuration                                           | `map(string)`  | `{ platformVersion = "LATEST" }`                                           | no       |
| secrets                                 | List of secrets linked to the job                                            | `map(string)`  | `{}`                                                                       | no       |
| task_definition_arn                     | ARN of the task definition associated with the ECS service                   | `string`       | `null`                                                                     | no       |
| task_definition_placement_constraints   | Placement constraints for the task definition                                | `map`          | `{}`                                                                       | no       |
| task_exec_iam_role_arn                  | ARN of the IAM role for task execution                                       | `string`       | `null`                                                                     | no       |
| task_exec_iam_role_description          | Description of the IAM role for task execution                               | `string`       | `null`                                                                     | no       |
| task_exec_iam_role_max_session_duration | Maximum session duration for the IAM task execution role                     | `number`       | `null`                                                                     | no       |
| task_exec_iam_role_name                 | Name of the IAM role for task execution                                      | `string`       | `null`                                                                     | no       |
| task_exec_iam_role_path                 | Path of the IAM role for task execution                                      | `string`       | `null`                                                                     | no       |
| task_exec_iam_role_permissions_boundary | Permission limit of the IAM role for task execution                          | `string`       | `null`                                                                     | no       |
| task_exec_iam_role_policies             | Policies of the IAM role for task execution                                  | `list`         | `{}`                                                                       | no       |
| task_exec_iam_role_tags                 | Tags of the IAM role for task execution                                      | `map`          | `{}`                                                                       | no       |
| task_exec_iam_role_use_name_prefix      | Indicates whether a prefix should be used for the IAM role name              | `bool`         | `true`                                                                     | no       |
| task_exec_iam_statements                | IAM statements for the task execution role                                   | `list`         | `{}`                                                                       | no       |
| task_exec_secret_arns                   | ARNs of the secrets for task execution                                       | `list`         | `["arn:aws:secretsmanager:*:*:secret:${local.common_name}-${each.key}-*"]` | no       |
| task_exec_ssm_param_arns                | ARNs of the SSM parameters for task execution                                | `list`         | `["arn:aws:ssm:*:*:parameter/batch/${local.common_name}-${each.key}-*"]`   | no       |
| task_tags                               | Tags for the tasks                                                           | `map`          | `{}`                                                                       | no       |
| tasks_iam_role_arn                      | ARN of the IAM role for the tasks                                            | `string`       | `null`                                                                     | no       |
| tasks_iam_role_description              | Description of the IAM role for the tasks                                    | `string`       | `null`                                                                     | no       |
| tasks_iam_role_name                     | Name of the IAM role for the tasks                                           | `string`       | `null`                                                                     | no       |
| tasks_iam_role_path                     | Path of the IAM role for the tasks                                           | `string`       | `null`                                                                     | no       |
| tasks_iam_role_permissions_boundary     | Permission limit of the IAM role for the tasks                               | `string`       | `null`                                                                     | no       |
| tasks_iam_role_policies                 | Policies of the IAM role for the tasks                                       | `list`         | `{}`                                                                       | no       |
| tasks_iam_role_statements               | IAM statements for the task role                                             | `list`         | `{}`                                                                       | no       |
| tasks_iam_role_tags                     | Tags of the IAM role for the tasks                                           | `map`          | `{}`                                                                       | no       |
| tasks_iam_role_use_name_prefix          | Indicates whether a prefix should be used for the IAM role name              | `bool`         | `true`                                                                     | no       |
| tags                                    | Tags that are added to all resources                                         | `map(string)`  | `{}`                                                                       | no       |








---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 