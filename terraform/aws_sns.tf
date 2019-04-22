resource "aws_sns_topic" "monitoring_alerts" {
    name = "${var.script_name}"
}