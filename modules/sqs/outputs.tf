output "main_sqs_url" {
  value = aws_sqs_queue.main_sqs.url
}

output "main_sqs_arn" {
  value = aws_sqs_queue.main_sqs.arn
}