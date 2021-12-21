resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
  number  = false
}

resource "aws_iam_role" "launch_template_ami_manager" {
  name = "launch-template-ami-manager-${var.name}-${random_string.random.result}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "launch_template_ami_manager" {
  name = "launch-template-ami-manager-${var.name}-${random_string.random.result}"
  role = aws_iam_role.launch_template_ami_manager.id

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
			"Action": "ec2:CreateLaunchTemplateVersion",
			"Effect": "Allow",
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": "iam:CreateServiceLinkedRole",
			"Resource": "*",
			"Condition": {
				"StringEquals": {
					"iam:AWSServiceName": [
						"autoscaling.amazonaws.com",
						"ec2scheduled.amazonaws.com",
						"elasticloadbalancing.amazonaws.com",
						"spot.amazonaws.com",
						"spotfleet.amazonaws.com",
						"transitgateway.amazonaws.com"
					]
				}
			}
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:DescribeAccountAttributes",
				"ec2:DescribeAvailabilityZones",
				"ec2:DescribeImages",
				"ec2:DescribeInstanceAttribute",
				"ec2:DescribeInstances",
				"ec2:DescribeKeyPairs",
				"ec2:DescribeLaunchTemplates",
				"ec2:DescribeLaunchTemplateVersions",
				"ec2:DescribePlacementGroups",
				"ec2:DescribeSecurityGroups",
				"ec2:DescribeSpotInstanceRequests",
				"ec2:DescribeSubnets",
				"ec2:DescribeVpcClassicLink"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"elasticloadbalancing:DescribeLoadBalancers",
				"elasticloadbalancing:DescribeTargetGroups"
			],
			"Resource": "*"
		},
		{
			"Action": [
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/launch-template-ami-manager-${var.name}-${random_string.random.result}:*",
			"Effect": "Allow"
		},
		{
			"Action": [
				"logs:CreateLogGroup"
			],
			"Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
			"Effect": "Allow"
		}
	]
}
EOF
}