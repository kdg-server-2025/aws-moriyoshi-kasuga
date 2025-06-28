# # CI/CD側でlambdaのソースコードを格納するための箱
# resource "aws_s3_bucket" "lambda_artifacts" {
#   bucket = "kdg-aws-2025-mori-lambda-artifacts"
#   tags = {
#     Name = "kdg-aws-2025-mori-lambda-artifacts"
#   }
# }
#
# # ロールを生成
# resource "aws_iam_role" "lambda" {
#   name = "iam_for_lambda"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         },
#         Effect = "Allow",
#         Sid    = ""
#       }
#     ]
#   })
# }
#
# # CloudWatch Logsへの書き込み権限を付与
# resource "aws_iam_role_policy_attachment" "lambda_logs" {
#   role       = aws_iam_role.lambda.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }
#
# # GetAccountSettings の権限をインラインポリシーとして付与
# resource "aws_iam_role_policy" "get_account_settings" {
#   name = "GetAccountSettingsPermission"
#   role = aws_iam_role.lambda.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = "lambda:GetAccountSettings"
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }
#
# # 初回のみ利用する空のLambdaのファイルを生成
# data "archive_file" "initial_lambda_package" {
#   type        = "zip"
#   output_path = "${path.module}/.temp_files/lambda.zip"
#   source {
#     content  = "# empty"
#     filename = "hoge.txt"
#   }
# }
#
# # (初回のみ)空のLambdaのファイルをS3にアップロード
# resource "aws_s3_object" "lambda_file" {
#   bucket = aws_s3_bucket.lambda_artifacts.id
#   key    = "initial.zip"
#   source = "${path.module}/.temp_files/lambda.zip"
# }
#
# # Lambda関数を生成
# resource "aws_lambda_function" "first_function" {
#   function_name = "first-function"
#   role          = aws_iam_role.lambda.arn
#   handler       = "main.handler"
#   runtime       = "provided.al2023"
#   timeout       = 120
#   publish       = true
#   s3_bucket     = aws_s3_bucket.lambda_artifacts.id
#   s3_key        = aws_s3_object.lambda_file.key
# }
#
# # 外部からリクエストを飛ばすためのエンドポイント
# resource "aws_lambda_function_url" "first_function" {
#   function_name      = aws_lambda_function.first_function.function_name
#   authorization_type = "NONE"
# }
