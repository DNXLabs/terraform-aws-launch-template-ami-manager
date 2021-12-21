resource "aws_cloudwatch_event_rule" "launch_template_ami_manager" {
  name                = "launch-template-ami-manager-${var.name}-${random_string.random.result}"
  description         = "Updates Launch Template with the new AMI generated by EBS Lifecycle"
  schedule_expression = "cron(${var.schedule_expression})"
}

resource "aws_cloudwatch_event_target" "launch_template_ami_manager" {
  rule      = aws_cloudwatch_event_rule.launch_template_ami_manager.name
  target_id = "launch-template-ami-manager-${var.name}-${random_string.random.result}"
  arn       = aws_lambda_function.launch_template_ami_manager.arn
}

resource "aws_lambda_permission" "launch_template_ami_manager" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.launch_template_ami_manager.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.launch_template_ami_manager.arn
}