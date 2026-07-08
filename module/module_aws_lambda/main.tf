resource "aws_lambda_function" "this" {

  filename         = var.lambda_filename_zip  #"lambda_function_upload.zip"
  function_name    = var.lambda_function_name #"lambda_function_name"
  role             = aws_iam_role.this.arn    #var.lambda_role_arn
  handler          = var.lambda_handler       #"index.test"
  source_code_hash = filebase64sha256("./${var.lambda_filename_zip}")
  publish          = true
  runtime          = var.lambda_runtime

  environment {
    variables = {
      FUNCTION_NAME   = var.lambda_function_name,
      ALIAS_NAME      = var.lambda_alias_name,
      CURRENT_VERSION = var.lambda_func_current_version,
      TARGET_VERSION  = var.lambda_func_target_version
    }
  }
  depends_on = [aws_iam_role.this]
}


resource "aws_lambda_alias" "test_lambda_alias" {
  name             = var.lambda_alias_name #"VLatest"
  description      = "Alias for latest version"
  function_name    = aws_lambda_function.this.arn
  function_version = var.lambda_func_target_version #"$LATEST"

  # routing_config {
  #   additional_version_weights = {
  #     "2" = 0.5
  #   }
  # }
  depends_on = [aws_lambda_function.this]
}

resource "aws_iam_role" "this" {
  name = "iam-${var.lambda_function_name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}