# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.queue.arn
  enabled          = true
  function_name    = aws_lambda_function.sqs_processor.arn
  batch_size       = 1
}
# Data resource to archive Lambda function code
data "archive_file" "lambda_zip" {
    source_dir  = "${path.module}/python/"
    output_path = "${path.module}/python/lambda.zip"
    type        = "zip"
}
# Lambda function policy
resource "aws_iam_policy" "lambda_policy" {
    name        = "${var.resource_name}-lambda-policy"
    description = "${var.resource_name}-lambda-policy"
 
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bucket.arn}"
    },
    {
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sqs_queue.queue.arn}"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
# Lambda function role
resource "aws_iam_role" "iam_for_terraform_lambda" { 
    name = "${var.resource_name}-lambda-role"
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
# Role to Policy attachment
resource "aws_iam_role_policy_attachment" "terraform_lambda_iam_policy_basic_execution" {
    role = aws_iam_role.iam_for_terraform_lambda.id
    policy_arn = aws_iam_policy.lambda_policy.arn
}
# Lambda function declaration
resource "aws_lambda_function" "sqs_processor" {
    filename = "${path.module}/python/lambda.zip"
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    function_name = "${var.resource_name}-lambda"
    role = aws_iam_role.iam_for_terraform_lambda.arn
    handler = "lambda.handler"
    runtime = "python3.8"
}
# CloudWatch Log Group for the Lambda function
resource "aws_cloudwatch_log_group" "lambda_loggroup" {
    name = "/aws/lambda/${aws_lambda_function.sqs_processor.function_name}"
    retention_in_days = 14
}