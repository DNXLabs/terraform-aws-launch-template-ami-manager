
data "archive_file" "launch_template_ami_manager" {
  type        = "zip"
  source_file = "${path.module}/lambda/launch-template-ami-manager.py"
  output_path = "launch-template-ami-manager-${var.name}-${random_string.random.result}.py.zip"
}

resource "aws_lambda_function" "launch_template_ami_manager" {
  filename         = data.archive_file.launch_template_ami_manager.output_path
  function_name    = "launch-template-ami-manager-${var.name}-${random_string.random.result}"
  role             = aws_iam_role.launch_template_ami_manager.arn
  handler          = "launch-template-ami-manager.lambda_handler"
  source_code_hash = data.archive_file.launch_template_ami_manager.output_base64sha256
  timeout          = 300

  runtime = "python3.8"

  environment {
    variables = {
      ami_tag_value = jsonencode(split(",", var.ami_tag_value)),
    }
  }
}
