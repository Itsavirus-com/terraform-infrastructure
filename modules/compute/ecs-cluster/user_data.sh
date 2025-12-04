#!/bin/bash

# Update system packages
yum update -y

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Configure ECS agent
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true >> /etc/ecs/ecs.config

# Enable ECS log collection
echo ECS_AVAILABLE_LOGGING_DRIVERS='["json-file","awslogs"]' >> /etc/ecs/ecs.config

# Enable execute command
echo ECS_ENABLE_TASK_ENI=true >> /etc/ecs/ecs.config

# Install SSM agent (for enhanced monitoring and debugging)
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Start ECS service
systemctl enable ecs
systemctl start ecs

# Additional user data
${additional_user_data}

# Send signal that instance is ready
/opt/aws/bin/cfn-signal -e $? --stack $${AWS::StackName} --resource AutoScalingGroup --region $${AWS::Region} || true 