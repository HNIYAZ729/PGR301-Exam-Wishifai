resource "aws_cloudwatch_dashboard" "wishifai" {
  dashboard_name = "wishifai-41-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Antall bildeanalyseforsøk"
          region = var.aws_region
          metrics = [
            ["wishifai", "wishifai.analysis.count.count"]
          ]
          period = 60
          stat   = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "ECS CPU-bruk"
          region = var.aws_region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "wishifai-41", "ClusterName", "default"]
          ]
          period = 60
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "JVM-minnebruk"
          region = var.aws_region
          metrics = [
            ["wishifai", "jvm.memory.used.value", "area", "heap", "id", "G1 Survivor Space"]
          ]
          period = 60
          stat   = "Average"
        }

      }
    ]

  })
}

resource "aws_cloudwatch_metric_alarm" "wishifai_analysis" {
  alarm_name          = "wishifai-41-analysis-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "wishifai.analysis.count.count"
  namespace           = "wishifai"
  period              = 300
  statistic           = "Sum"
  threshold           = 20

  alarm_description  = "Varsler ved mer enn 20 bildeanalyseforsok pa 5 minutter"
  treat_missing_data = "notBreaching"
}
