variable "name" {
  description = "App name"
}
variable "ami_tag_value" {
  description = "Tag value to identify which AMIs (latest) will be updated in the launch template."
}

variable "schedule_expression" {
  description = "CRON expression to invoke the lambda"
}