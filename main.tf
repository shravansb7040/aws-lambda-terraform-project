provider "aws" {
  region = "ap-south-1"
}

resource "aws_iam_role" "lambda_role" {
  name               = "terraform_aws_lambda_role"
  assume_role_policy = file("${path.module}/iam-policies/iam-role-policy.json")
}

# IAM policy for logging from a lambda

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = file("${path.module}/iam-policies/iam-lambda-logging-policy.json")
}

# Policy Attachment on the role.

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# Create a lambda function
# In terraform ${path.module} is the current directory.
resource "aws_lambda_function" "terraform_lambda_func" {
  filename      = "/Users/shravansb/Documents/code-projects/test-lambda-function/target/test-lambda-function.jar"
  function_name = "Java-Lambda-Function-Test"
  role          = aws_iam_role.lambda_role.arn
  handler       = "com.shravan.lambda.HealthCheckFunction::handleRequest"
  runtime       = "java17"
  timeout       = "900"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  description   = "Testing Lambda Creation from Terraform"
}


output "teraform_aws_role_output" {
  value = aws_iam_role.lambda_role.name
}

output "teraform_aws_role_arn_output" {
  value = aws_iam_role.lambda_role.arn
}

output "teraform_logging_arn_output" {
  value = aws_iam_policy.iam_policy_for_lambda.arn
}
