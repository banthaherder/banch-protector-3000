resource "aws_iam_role" "iam_for_lambda" {
  name = "BranchProtectorRole"

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

resource "aws_iam_policy" "parameter_store" {
  name        = "BranchProtectorParameterStore"
  description = "Allows a lmabda to read from parameter store"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameter*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "kms:Decrypt*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "parameter_store" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.parameter_store.arn}"
}

resource "aws_lambda_function" "branch_protector" {
  filename         = "../dist/github_org_webhook.zip"
  function_name    = "BranchProtector"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = "${filebase64sha256("../dist/github_org_webhook.zip")}"
  timeout          = 15
  runtime          = "python3.7"

  environment {
    variables = {
      REGION      = "us-west-2",
      NOTIFY_USER = "banthaherder",
      SSM_PREFIX  = "BRANCH_PROTECTOR"
    }
  }
}


resource "aws_lambda_permission" "alb" {
  statement_id  = "AllowExecutionFromlb"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.branch_protector.arn}"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = "${aws_lb_target_group.github_hook.arn}"
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = "${aws_lb_target_group.github_hook.arn}"
  target_id        = "${aws_lambda_function.branch_protector.arn}"
  depends_on       = ["aws_lambda_permission.alb"]
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "LambdaLogging"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": "arn:aws:logs:us-west-2:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:us-west-2:*:log-group:/aws/lambda/${aws_lambda_function.branch_protector.function_name}:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}
