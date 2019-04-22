resource "aws_cloudwatch_event_rule" "monitor" {
    name        = "RunMonitoringScript"
    description = "Run monitoring script every 1 minute."
    schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda" {
    rule = "${aws_cloudwatch_event_rule.monitor.name}"
    arn = "${aws_lambda_function.monitoring_lambda.arn}"
}