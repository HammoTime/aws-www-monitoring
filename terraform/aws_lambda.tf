resource "aws_lambda_function" "monitoring_lambda" {
    filename         = "${path.module}/assets/lambda_function_payload.zip"
    function_name    = "${var.script_name}"
    role             = "${aws_iam_role.iam_for_lambda.arn}"
    handler          = "run.monitor"
    source_code_hash = "${data.archive_file.lambda_payload.output_base64sha256}"
    runtime          = "python3.7"
    timeout          = "300"

    environment {
        variables = {
            SNS_TOPIC_ARN = "${aws_sns_topic.monitoring_alerts.arn}"
        }
    }

    depends_on = [ "data.archive_file.lambda_payload" ]
}

resource "aws_lambda_permission" "cloudwatch_events_permission" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.monitoring_lambda.function_name}"
    principal     = "events.amazonaws.com"
    source_arn    = "${aws_cloudwatch_event_rule.monitor.arn}"
}

data "archive_file" "lambda_payload" {
    type        = "zip"
    source_file = "${path.module}/../run.py"
    output_path = "${path.module}/assets/lambda_function_payload.zip"
}