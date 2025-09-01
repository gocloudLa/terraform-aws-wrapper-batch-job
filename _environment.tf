locals {
  batch_job_environments = {
    for job_key, job in var.batch_job_parameters :
    job_key => [
      for env_key, env_value in try(job.map_environment, {}) :
      {
        name  = env_key
        value = env_value
      }
    ]
  }
}
