/*----------------------------------------------------------------------*/
/* Batch_job | Variable Definition                                      */
/*----------------------------------------------------------------------*/

variable "batch_job_parameters" {
  type        = any
  description = ""
  default     = {}
}

variable "batch_job_defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}