resource "aws_iam_role" "iam_for_lambda" {
    name = "iam_for_lambda"

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

resource "aws_iam_role" "iam_for_cloudwatch_events" {
    name = "iam_for_cloudwatch_events"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "events.amazonaws.com"
        },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
    EOF
}

resource "aws_iam_policy" "execute_lambda_policy" {
    name        = "execute_lambda_policy"
    description = "Allows execution of Lambda Functions"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "*"
        }
    ]
}
    EOF
}

resource "aws_iam_role_policy_attachment" "route53_policy_attachment" {
    role       = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
    role       = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_events_policy_attachment" {
    role       = "${aws_iam_role.iam_for_cloudwatch_events.name}"
    policy_arn = "${aws_iam_policy.execute_lambda_policy.arn}"
}
