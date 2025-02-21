- name: ${container_name}
  image: ${frontend_nextjs_image_url}
  essential: true
  environment:
    - name: GRPC_BACKEND_URL
      value: ${grpc_backend_url}
    - name: SQS_ADDRESS
      value: ${sqs_address}
  logConfiguration:
    logDriver: awslogs
    options:
      awslogs-group: ${log_group}
      awslogs-region: ${aws_region}
      awslogs-stream-prefix: ${log_stream_prefix}