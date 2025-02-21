- name: ${container_name}
  image: ${backend_grpc_image_url}
  essential: true
  logConfiguration:
    logDriver: awslogs
    options:
      awslogs-group: ${log_group}
      awslogs-region: ${aws_region}
      awslogs-stream-prefix: ${log_stream_prefix}