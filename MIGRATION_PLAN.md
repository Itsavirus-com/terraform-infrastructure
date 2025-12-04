# Terraform Module Remapping Plan

## Current Structure Issues

- Multiple production variants: `production/`, `production-ecs/`, `production-ecs-new/`
- Mixed infrastructure and application concerns
- Significant code duplication
- Inconsistent module organization patterns

## Target Structure

```
modules/
├── compute/
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── ecs-cluster/
│   │   ├── main.tf           # ECS cluster, ASG, launch templates
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── ecs-service/
│       ├── main.tf           # ECS service, task definition, ECR
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── networking/
│   ├── vpc/
│   │   ├── main.tf           # VPC, subnets, IGW, route tables
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── load-balancer/
│       ├── main.tf           # ALB, target groups, listeners
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── storage/
│   ├── s3/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── rds/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── security/
│   ├── security-groups/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── iam/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── messaging/
│   ├── ses/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── sqs/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── monitoring/
│   └── cloudwatch/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
└── container-registry/
    └── ecr/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── versions.tf
```

## Migration Steps

### Phase 1: Create New Module Structure (Non-Breaking)

1. Create new `modules/` directory structure
2. Consolidate and clean up duplicated code
3. Extract reusable components from current modules
4. Add proper variable validation and outputs

### Phase 2: Migrate Projects (One by One)

1. Start with staging/development environments
2. Update project configurations to use new modules
3. Test thoroughly before migrating production
4. Update documentation and examples

### Phase 3: Cleanup (Breaking Changes)

1. Remove old `terraform-modules/` directory
2. Update any remaining references
3. Clean up unused resources

## Resource Mapping

### From Current Modules → New Modules:

**VPC & Networking:**

- `production-ecs-new/vnet/` → `modules/networking/vpc/`
- `production-ecs-new/loadbalancer/` → `modules/networking/load-balancer/`
- Security groups scattered across modules → `modules/security/security-groups/`

**Compute:**

- `production-ecs-new/ec2/` → `modules/compute/ec2/`
- `production-ecs-new/ecs/` → `modules/compute/ecs-cluster/`
- `production-ecs-new/ecs-service/*-ecs/` → `modules/compute/ecs-service/`

**Storage:**

- `production-ecs-new/s3*/` → `modules/storage/s3/`
- `production-ecs-new/rds/` → `modules/storage/rds/`

**Container & Registry:**

- `production-ecs-new/ecr/` → `modules/container-registry/ecr/`

**Messaging:**

- `production-ecs-new/ses/` → `modules/messaging/ses/`
- `production-ecs-new/sqs/` → `modules/messaging/sqs/`

**Monitoring:**

- `production-ecs-new/cloudwatch/` → `modules/monitoring/cloudwatch/`

## Benefits After Migration

1. **Single Source of Truth:** One well-designed module per service type
2. **Consistent Interface:** Standardized variables, outputs, and patterns
3. **Better Reusability:** Modules work across all environments and projects
4. **Easier Maintenance:** Clear ownership and update path for each component
5. **Improved Testing:** Focused modules are easier to test in isolation

## Next Steps

1. Review and approve this plan
2. Begin Phase 1 implementation
3. Create migration scripts for automated conversion
4. Set up CI/CD validation for new modules
