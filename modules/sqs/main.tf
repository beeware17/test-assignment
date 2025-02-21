resource "aws_sqs_queue" "main_sqs" {
  name = format(local.resource_name, "main-sqs")
  tags = merge(local.common_tags, { "Name" : format(local.resource_name, "main-sqs") })
}