resource "null_resource" "pip" {
  triggers = {
    main         = base64sha256(file("${path.root}/../python/main.py"))
    requirements = base64sha256(file("${path.root}/../python/requirements.txt"))
  }

  provisioner "local-exec" {
    command = "${var.pip_path} install -r ${path.root}/../python/requirements.txt -t lambda/lib"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../python/"
  output_path = "${path.root}/../lambda.zip"

  depends_on = [null_resource.pip]
}


resource "aws_iam_role" "lambda_iam" {
  name = var.lambda_iam_name
  assume_role_policy = file("${path.module}/policy.json")
}

resource "aws_lambda_function" "lambda" {
  filename         = "${path.root}/../lambda.zip"
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_iam.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.6"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

output "lambda_arn" {
  value = aws_lambda_function.lambda.arn
}

output "lambda_name" {
  value = aws_lambda_function.lambda.function_name
}
