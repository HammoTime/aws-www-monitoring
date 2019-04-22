import boto3
import json
import time
import os

if os.environ.get("AWS_EXECUTION_ENV") is None:
    import requests
else:
    from botocore.vendored import requests

def put_metric(subdomain_name, up):
    if up:
        metric_value = 1
    else:
        metric_value = 0

    cloudwatch = boto3.client('cloudwatch')
    cloudwatch.put_metric_data(
        Namespace='Website',
        MetricData=[
            {
                "MetricName": "UrlAvailability",
                "Dimensions": [
                    {
                        "Name": "Subdomain",
                        "Value": subdomain_name
                    }
                ],
                "Timestamp": time.time(),
                "Value": metric_value,
                "StorageResolution": 1
            }
        ]
    )

def create_alarm(subdomain_name, sns_topic):
    cloudwatch = boto3.client('cloudwatch')
    cloudwatch.put_metric_alarm(
        AlarmName=subdomain_name,
        AlarmDescription="Status Monitoring for '" + subdomain_name + "'.",
        ActionsEnabled=True,
        OKActions=[
            sns_topic
        ],
        AlarmActions=[
            sns_topic
        ],
        MetricName="UrlAvailability",
        Namespace="Website",
        Dimensions=[
            {
                "Name": "Subdomain",
                "Value": subdomain_name
            }
        ],
        Period=60,
        Threshold=1,
        Statistic="Average",
        DatapointsToAlarm=2,
        EvaluationPeriods=10,
        ComparisonOperator="LessThanThreshold",
        TreatMissingData="breaching"
    )

def monitor(event, context): 
    route53 = boto3.client('route53')
    hosted_zones = route53.list_hosted_zones()

    for hosted_zone in hosted_zones["HostedZones"]:
        domain = hosted_zone["Name"]
        config = hosted_zone["Config"]["Comment"].split(";")
        should_monitor = config[0]
        subdomain = config[1]
        full_subdomain = subdomain + "." + domain
        availability = config[2]
        url = "https://" + full_subdomain
        sns_topic_arn = os.environ["SNS_TOPIC_ARN"]

        print(" ")
        print("Checking domain status for '" + domain + "'.")
        print("The website endpoint is: '" + subdomain + "'.")
        print("This website is supposed to be up '" + availability + "'.")

        if should_monitor == "on":
            create_alarm(url, sns_topic_arn)

            try:
                request = requests.get(url, verify=False) # for some reason SNI not working even though python37
                if(request.status_code == 200):
                    print("Website UP!")
                    put_metric(url, True)
                else:
                    print("Website DOWN!")
                    put_metric(url, False)
            except Exception as ex:
                print("Website DOWN!")
                print(ex)
                put_metric(url, False)
        else:
            print("Monitoring OFF, skipping.")
    
    print(" ")
    print("Monitoring execution complete.")

if os.environ.get("AWS_EXECUTION_ENV") is None:
    monitor(None, None)