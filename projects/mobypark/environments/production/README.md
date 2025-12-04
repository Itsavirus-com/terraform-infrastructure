# MobyPark Production Environment

This directory contains the complete **production infrastructure** for MobyPark using containerized ECS services with auto-scaling EC2 instances, load balancing, and SSL termination.

## 🏗️ Architecture Overview

```
Internet → Route53 → ALB (HTTPS) → ECS Services → Auto-Scaling EC2 → Database
                ↓
            ACM Certificate
```

### Infrastructure Components

- **🌐 VPC**: Isolated network with public/private subnets across 3 AZs
- **🔒 Security Groups**: Tiered security (ALB, Application, Database)
- **📜 SSL Certificate**: Auto-managed ACM certificate with DNS validation
- **⚖️ Load Balancer**: Application Load Balancer with HTTP→HTTPS redirect
- **🐳 ECS Cluster**: Auto-scaling EC2 instances with capacity providers
- **🔑 IAM Roles**: Least-privilege roles for execution and task permissions

### MobyPark Services

1. **Backend API** (`/api/*`) - Core parking management API
2. **Frontend Web** (`/*`) - React/Vue.js customer interface
3. **Admin Dashboard** (`/admin/*`) - Management interface
4. **Background Workers** - Payment processing, notifications, data sync

## 📋 Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **Route53 hosted zone** for your domain
4. **S3 bucket** for Terraform state storage
5. **DynamoDB table** for state locking

### Required AWS Resources (to be created separately)

Before deploying this infrastructure, ensure these external resources exist:

```bash
# S3 buckets
aws s3 mb s3://mobypark-prod-config
aws s3 mb s3://mobypark-prod-parking-data
aws s3 mb s3://mobypark-prod-media
aws s3 mb s3://mobypark-prod-backups

# Secrets Manager
aws secretsmanager create-secret --name mobypark-prod-db-credentials \
  --secret-string '{"password":"your-secure-password"}'
aws secretsmanager create-secret --name mobypark-prod-jwt-secret \
  --secret-string '{"jwt_secret":"your-jwt-secret"}'

# SQS queues
aws sqs create-queue --queue-name mobypark-prod-notifications
aws sqs create-queue --queue-name mobypark-prod-payments
aws sqs create-queue --queue-name mobypark-prod-bookings

# DynamoDB tables
aws dynamodb create-table --table-name mobypark-prod-sessions \
  --attribute-definitions AttributeName=session_id,AttributeType=S \
  --key-schema AttributeName=session_id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# SNS topics
aws sns create-topic --name mobypark-prod-notifications
```

## 🚀 Deployment Guide

### 1. Configure Variables

```bash
# Copy and configure secrets
cp secrets.tfvars.example secrets.tfvars
# Edit secrets.tfvars with actual ARNs and values

# Review terraform.tfvars
vim terraform.tfvars
```

### 2. Initialize Terraform

```bash
# Initialize backend and providers
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

### 3. Plan and Deploy

```bash
# Create execution plan
terraform plan -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Deploy infrastructure
terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"
```

### 4. Deploy Applications

After infrastructure is ready:

```bash
# Get ECR repository URLs
BACKEND_ECR=$(terraform output -raw backend_ecr_url)
FRONTEND_ECR=$(terraform output -raw frontend_ecr_url)
ADMIN_ECR=$(terraform output -raw admin_ecr_url)
WORKER_ECR=$(terraform output -raw worker_ecr_url)

# Login to ECR
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $BACKEND_ECR

# Build and push images
docker build -t mobypark-backend ./backend
docker tag mobypark-backend:latest $BACKEND_ECR:latest
docker push $BACKEND_ECR:latest

docker build -t mobypark-frontend ./frontend
docker tag mobypark-frontend:latest $FRONTEND_ECR:latest
docker push $FRONTEND_ECR:latest

# Update ECS services
aws ecs update-service --cluster mobypark-prod-cluster \
  --service mobypark-prod-backend-service --force-new-deployment

aws ecs update-service --cluster mobypark-prod-cluster \
  --service mobypark-prod-frontend-service --force-new-deployment
```

## 🎯 Service Configuration

### Environment Variables

Store environment files in S3:

```bash
# Upload environment configuration
aws s3 cp production.env s3://mobypark-prod-config/production.env
aws s3 cp admin.env s3://mobypark-prod-config/admin.env
```

Example `production.env`:

```bash
NODE_ENV=production
LOG_LEVEL=info
DATABASE_HOST=mobypark-prod.cluster-xyz.eu-west-1.rds.amazonaws.com
DATABASE_NAME=mobypark
REDIS_HOST=mobypark-prod.abc123.cache.amazonaws.com
API_RATE_LIMIT=1000
PAYMENT_PROVIDER=stripe
```

### DNS Configuration

After deployment, create DNS records:

```bash
# Get load balancer DNS name
ALB_DNS=$(terraform output -raw load_balancer_dns_name)
ALB_ZONE=$(terraform output -raw load_balancer_zone_id)

# Create Route53 records
aws route53 change-resource-record-sets --hosted-zone-id Z123456789 --change-batch '{
  "Changes": [{
    "Action": "CREATE",
    "ResourceRecordSet": {
      "Name": "mobypark.com",
      "Type": "A",
      "AliasTarget": {
        "DNSName": "'$ALB_DNS'",
        "EvaluateTargetHealth": false,
        "HostedZoneId": "'$ALB_ZONE'"
      }
    }
  }]
}'
```

## 📊 Monitoring & Maintenance

### CloudWatch Logs

```bash
# View service logs
aws logs tail /ecs/mobypark-prod-backend --follow
aws logs tail /ecs/mobypark-prod-frontend --follow
aws logs tail /ecs/mobypark-prod-admin --follow
aws logs tail /ecs/mobypark-prod-worker --follow
```

### ECS Service Status

```bash
# Check all services
aws ecs describe-services --cluster mobypark-prod-cluster \
  --services mobypark-prod-backend-service mobypark-prod-frontend-service \
             mobypark-prod-admin-service mobypark-prod-worker-service

# Check auto scaling
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names mobypark-prod-ecs-asg
```

### Health Checks

```bash
# Service health endpoints
curl -f https://mobypark.com/health
curl -f https://mobypark.com/api/health
curl -f https://mobypark.com/admin/health
```

### Scaling Operations

```bash
# Scale backend service
aws ecs update-service --cluster mobypark-prod-cluster \
  --service mobypark-prod-backend-service --desired-count 6

# Scale ECS cluster
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name mobypark-prod-ecs-asg \
  --desired-capacity 8
```

## 🔧 Troubleshooting

### Common Issues

1. **Service won't start**: Check CloudWatch logs and task definition
2. **Load balancer unhealthy**: Verify health check endpoints
3. **Auto scaling not working**: Check capacity provider configuration
4. **SSL certificate issues**: Verify Route53 DNS validation

### Debug Commands

```bash
# Check ECS tasks
aws ecs list-tasks --cluster mobypark-prod-cluster
aws ecs describe-tasks --cluster mobypark-prod-cluster --tasks TASK_ARN

# Check target group health
aws elbv2 describe-target-health --target-group-arn TARGET_GROUP_ARN

# View capacity provider metrics
aws ecs describe-capacity-providers --capacity-providers mobypark-prod-capacity-provider
```

## 🔒 Security Features

- ✅ **VPC isolation** with private subnets for applications
- ✅ **Security groups** with minimal required access
- ✅ **IAM roles** with least privilege principle
- ✅ **Encrypted storage** (EBS volumes, S3, RDS)
- ✅ **SSL/TLS termination** with modern cipher suites
- ✅ **Secrets management** via AWS Secrets Manager
- ✅ **Network security** with WAF-ready ALB

## 🚦 Production Readiness

This infrastructure provides:

- ⚡ **High availability** across multiple AZs
- 🔄 **Auto scaling** based on demand
- 📈 **Monitoring** with CloudWatch Container Insights
- 🔐 **Security** with defense in depth
- 🚀 **CI/CD ready** with ECR integration
- 💰 **Cost optimized** with spot instances and efficient scaling

---

## 📞 Support

For infrastructure issues or questions, contact the DevOps team or create an issue in the infrastructure repository.

**Important URLs:**

- Production: https://mobypark.com
- Admin Panel: https://mobypark.com/admin
- API Docs: https://mobypark.com/docs
- Health Check: https://mobypark.com/health
