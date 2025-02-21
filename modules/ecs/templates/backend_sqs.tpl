- name: ${container_name}
  image: ${backend_sqs_image_url}
  essential: true
  environment:
    - name: SQS_ADDRESS
      value: ${sqs_address}
  logConfiguration:
    logDriver: awslogs
    options:
      awslogs-group: ${log_group}
      awslogs-region: ${aws_region}
      awslogs-stream-prefix: ${log_stream_prefix}