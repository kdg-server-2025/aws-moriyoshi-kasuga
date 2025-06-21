variable "notification_email" {
  description = "Email address to receive budget alerts"
  type        = string
}


resource "aws_sns_topic" "budget_alert" {
  name = "budget-alert-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.budget_alert.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

locals {
  budget_levels = [
    { name = "budget-1", amount = 1 },
    { name = "budget-5", amount = 5 },
    { name = "budget-10", amount = 10 }
  ]
}


resource "aws_budgets_budget" "budget" {
  for_each     = { for b in local.budget_levels : b.name => b }
  name         = each.value.name
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = each.value.amount
  limit_unit   = "USD"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.budget_alert.arn]
  }
}
