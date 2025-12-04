# Terraform Best Practices for Itsavirus Projects

> **Document Version:** 1.0  
> **Last Updated:** 2024  
> **Purpose:** A friendly guide for all developers to understand and work with our infrastructure code

---

## 📋 Table of Contents

1. [What is Terraform? (For Non-Cloud Engineers)](#what-is-terraform-for-non-cloud-engineers)
2. [Repository Structure](#repository-structure)
3. [Understanding the File Structure](#understanding-the-file-structure)
4. [Module Design Principles](#module-design-principles)
5. [Project Organization](#project-organization)
6. [State Management (Why It Matters)](#state-management-why-it-matters)
7. [Security Best Practices](#security-best-practices)
8. [Variable Management](#variable-management)
9. [Tagging Strategy](#tagging-strategy)
10. [Version Control](#version-control)
11. [Security Scanning](#security-scanning)
12. [Daily Workflows](#daily-workflows)
13. [Common Patterns Explained](#common-patterns-explained)
14. [Quick Reference Guide](#quick-reference-guide)

---

## 🤔 What is Terraform? (For Non-Cloud Engineers)

### The Simple Explanation

Think of Terraform like a **recipe book for your cloud infrastructure**. Just like a recipe tells you exactly what ingredients you need and how to combine them to make a cake, Terraform tells AWS exactly what servers, databases, and networking you need to run your application.

### Real-World Analogy

Imagine you're building a house:

- **Terraform code** = The architectural blueprint
- **AWS resources** = The actual house (servers, databases, etc.)
- **Terraform state** = A record of what you've already built
- **Modules** = Reusable building components (like pre-made windows or doors)

### Why We Use Terraform

1. **Consistency**: The same code always creates the same infrastructure
2. **Version Control**: We can see what changed and when (like Git for infrastructure)
3. **Reproducibility**: We can recreate the exact same setup in different environments
4. **Safety**: We can preview changes before applying them (like a dry run)

### Key Concepts Made Simple

| Terraform Term | What It Really Means                  | Real-World Example                                        |
| -------------- | ------------------------------------- | --------------------------------------------------------- |
| **Resource**   | A single piece of infrastructure      | A server, a database, a load balancer                     |
| **Module**     | A reusable set of resources           | Like a "web server package" you can reuse                 |
| **State**      | Terraform's memory of what exists     | Like a shopping list of what you've already bought        |
| **Provider**   | The cloud platform (AWS, Azure, etc.) | The store where you're buying your infrastructure         |
| **Variable**   | A configurable value                  | Like a setting you can change (server size, region, etc.) |
| **Output**     | Information about what was created    | Like a receipt showing what you built                     |

---

## 🏗️ Repository Structure

### How Our Code is Organized

Our Terraform code is organized like a well-structured library:

```
terraform-infrastructure/
├── key-pairs/              # 🔑 SSH keys (like passwords for server access)
├── modules/                # 📚 Reusable building blocks (like LEGO pieces)
│   ├── compute/            # 💻 Servers and containers
│   ├── networking/         # 🌐 Network setup (like roads and bridges)
│   ├── security/           # 🔒 Security settings (permissions, certificates)
│   └── storage/            # 💾 Databases and file storage
├── projects/               # 📁 Each client project has its own folder
│   └── {project-name}/
│       └── environments/   # 🏢 Separate configs for staging and production
│           ├── staging/    # 🧪 Testing environment
│           └── production/ # 🚀 Live environment
└── terraform-modules/      # 📦 Legacy modules (older code)
```

### Why This Structure?

- **Modules** = Reusable code (write once, use many times)
- **Projects** = Each client gets their own folder
- **Environments** = Separate staging and production (like having a test kitchen and a real restaurant)

**Think of it like this:**

- Modules = Pre-built furniture pieces
- Projects = Different houses using those pieces
- Environments = Different rooms in each house (staging = practice room, production = main room)

---

## 📄 Understanding the File Structure

### What Each File Does

When you look at a project folder, you'll see several `.tf` files. Here's what each one does in simple terms:

#### `main.tf` - The Main Recipe

**What it does:** This is where we put together all the pieces (modules) to build our infrastructure.

**Think of it as:** The main recipe that combines ingredients (modules) to make a complete meal.

**Example:**

```hcl
# This creates a virtual network (like a private neighborhood)
module "vpc" {
  source = "../../../../modules/networking/vpc"
  name_prefix = "my-project"
  # ... more settings
}

# This creates a server cluster (like a group of computers)
module "ecs_cluster" {
  source = "../../../../modules/compute/ecs-cluster"
  name_prefix = "my-project"
  # ... more settings
}
```

#### `variables.tf` - The Settings Menu

**What it does:** Defines all the configurable options (like a settings menu in a video game).

**Think of it as:** A form where you fill in your preferences before building.

**Example:**

```hcl
variable "project_name" {
  description = "What should we call this project?"
  type        = string
  # No default = you MUST provide this value
}

variable "server_size" {
  description = "How powerful should the servers be?"
  type        = string
  default     = "t3.small"  # Small server by default
}
```

#### `outputs.tf` - The Receipt

**What it does:** Shows important information about what was created (like URLs, IDs, etc.).

**Think of it as:** A receipt that shows what you built and how to access it.

**Example:**

```hcl
output "website_url" {
  description = "The URL where your website is accessible"
  value       = "https://${var.domain_name}"
}

output "database_endpoint" {
  description = "Where your database is located"
  value       = module.database.endpoint
}
```

#### `backend.tf` / `provider.tf` - The Connection Settings

**What it does:** Tells Terraform which cloud provider to use and where to save its "memory" (state).

**Think of it as:** Login credentials and where to save your work.

**Example:**

```hcl
# This says "use AWS cloud"
provider "aws" {
  region = "eu-central-1"  # Which AWS region (like which city)
}

# This says "save my state file in S3" (like saving your game progress in the cloud)
terraform {
  backend "s3" {
    bucket = "my-project-terraform-state"
    key    = "production/terraform.tfstate"
  }
}
```

#### `terraform.tfvars` - Your Custom Settings

**What it does:** Contains your actual values for the variables (like filling out the form).

**Think of it as:** Your saved preferences file.

**Example:**

```hcl
project_name = "mobypark"
environment  = "production"
server_size  = "t3.medium"
```

#### `secrets.tfvars` - Your Passwords (SECRET!)

**What it does:** Contains sensitive information like passwords and API keys.

**⚠️ IMPORTANT:** This file is NEVER committed to Git (it's in `.gitignore`).

**Think of it as:** Your password file that stays on your computer only.

---

## 🧩 Module Design Principles

### What is a Module?

A **module** is like a pre-built component you can reuse. Instead of writing the same code over and over, you create a module once and use it many times.

**Real-world analogy:**

- Without modules: Building each window from scratch every time
- With modules: Having a standard window design you can use in any house

### Module Structure

Every module follows this pattern:

```
modules/networking/vpc/
├── main.tf      # The actual code that creates resources
├── variables.tf # What inputs does this module need?
├── outputs.tf   # What information does this module provide?
└── versions.tf  # Which Terraform version is required?
```

### Best Practices for Modules

#### ✅ DO: Make Modules Flexible

**Good Example:**

```hcl
# This module can be used for any project
module "vpc" {
  source = "../../../../modules/networking/vpc"

  name_prefix = var.project_name  # ← Configurable
  vpc_cidr    = var.vpc_cidr      # ← Configurable
  # ... more configurable options
}
```

**Why this is good:** You can reuse this module for different projects by just changing the inputs.

#### ❌ DON'T: Hardcode Values

**Bad Example:**

```hcl
# This is bad - hardcoded values
module "vpc" {
  source = "../../../../modules/networking/vpc"
  name_prefix = "mobypark"  # ← Hardcoded! Can't reuse for other projects
}
```

**Why this is bad:** You'd need to create a new module for every project.

### Module Best Practices Checklist

- ✅ Use variables for all configurable values
- ✅ Provide sensible defaults when possible
- ✅ Add descriptions to all variables
- ✅ Output important information (IDs, URLs, etc.)
- ✅ Keep modules focused (one module = one purpose)
- ✅ Document how to use the module

---

## 📁 Project Organization

### Environment Separation

We keep **staging** and **production** completely separate. Think of it like having two separate kitchens:

- **Staging** = Test kitchen (you can experiment here)
- **Production** = Real restaurant kitchen (must be perfect)

### Directory Structure Explained

```
projects/mobypark/
└── environments/
    ├── staging/      # 🧪 Testing environment
    │   ├── main.tf
    │   ├── variables.tf
    │   └── terraform.tfvars
    └── production/   # 🚀 Live environment
        ├── main.tf
        ├── variables.tf
        └── terraform.tfvars
```

**Why separate?**

- Different configurations (staging might use smaller servers)
- Different secrets (production passwords are more sensitive)
- Safety (mistakes in staging don't affect production)

### File Responsibilities (Simple Version)

| File               | What It Does                         | When You Edit It                 |
| ------------------ | ------------------------------------ | -------------------------------- |
| `main.tf`          | Defines what infrastructure to build | When adding new services         |
| `variables.tf`     | Lists all configurable options       | When adding new settings         |
| `outputs.tf`       | Shows important information          | When you need to expose new info |
| `terraform.tfvars` | Your actual configuration values     | When changing settings           |
| `secrets.tfvars`   | Passwords and sensitive data         | When updating credentials        |

---

## 💾 State Management (Why It Matters)

### What is Terraform State?

**Simple explanation:** Terraform state is like Terraform's memory. It remembers:

- What resources it created
- What their IDs are
- How they're connected

**Real-world analogy:**

- Without state: Like trying to remember what you bought at the grocery store
- With state: Like keeping a receipt of everything you bought

### Why State Matters

1. **Terraform needs to know what exists** to update or delete resources
2. **State prevents conflicts** when multiple people work on the same infrastructure
3. **State tracks relationships** between resources

### Remote State (The Cloud Backup)

Instead of keeping state files on your computer, we store them in AWS S3 (like cloud storage).

**Why?**

- ✅ Multiple people can work on the same infrastructure
- ✅ State is backed up automatically
- ✅ Prevents conflicts (like a lock on a file)

### State File Security

**⚠️ CRITICAL RULES:**

1. **Never commit state files to Git**

   - They contain sensitive information
   - They're automatically ignored (in `.gitignore`)

2. **Use separate state for each environment**

   - Staging and production must have separate state files
   - This prevents accidentally affecting production

3. **Always use remote state in production**
   - Local state files can be lost or corrupted
   - Remote state is safer and more reliable

### How State Works (Simple Flow)

```
1. You write Terraform code
   ↓
2. You run `terraform plan` (preview changes)
   ↓
3. Terraform reads the state file to see what exists
   ↓
4. Terraform compares code vs. state
   ↓
5. Terraform shows you what will change
   ↓
6. You run `terraform apply` (make changes)
   ↓
7. Terraform updates the state file with new information
```

---

## 🔒 Security Best Practices

### Why Security Matters

Just like you lock your house, we need to secure our cloud infrastructure. Security in Terraform means:

- Controlling who can access what
- Encrypting sensitive data
- Following the "least privilege" principle (only give access to what's needed)

### 1. IAM Roles (Who Can Do What)

**What is IAM?** Identity and Access Management - it's like a security system that controls who can access what.

**Simple explanation:**

- **Execution Role** = What the container needs to START (like a key to start a car)
- **Task Role** = What the application needs to RUN (like permissions to use features)

**Example:**

```hcl
# This gives the container permission to read environment files from S3
module "iam_roles" {
  source = "../../../../modules/security/iam"

  # Allow reading config files
  enable_s3_env_files = true

  # Allow sending emails
  enable_task_ses_access = true

  # Allow writing logs
  enable_task_cloudwatch_access = true
}
```

**Best Practice:** Only give the minimum permissions needed (principle of least privilege).

### 2. Security Groups (Firewall Rules)

**What are Security Groups?** They're like a firewall that controls what network traffic is allowed.

**Simple explanation:**

- Security groups = Rules about who can talk to your servers
- Like a bouncer at a club checking IDs

**Example:**

```hcl
# Only allow traffic from within our private network
application_ingress_rules = [
  {
    from_port   = 8000      # Port number (like a door number)
    to_port     = 8000
    protocol    = "tcp"     # Type of connection
    cidr_blocks = ["10.10.0.0/16"]  # Only from our private network
    description = "Backend API port"
  }
]
```

**Best Practice:** Only open the ports you actually need.

### 3. Encryption (Scrambling Data)

**Why encrypt?** So if someone gets access to your data, they can't read it.

**Simple explanation:** Encryption = Turning your data into a secret code

**What we encrypt:**

- ✅ Server hard drives (EBS volumes)
- ✅ Database storage
- ✅ Container image storage (ECR)
- ✅ All data in transit (HTTPS/SSL)

**Example:**

```hcl
# Always encrypt server storage
encrypt_root_volume = true
```

### 4. Secrets Management (Password Storage)

**⚠️ NEVER do this:**

```hcl
# ❌ BAD - Password in code!
environment_variables = [
  {
    name  = "DATABASE_PASSWORD"
    value = "my-secret-password"  # ← NEVER DO THIS!
  }
]
```

**✅ ALWAYS do this:**

```hcl
# ✅ GOOD - Password from AWS Secrets Manager
secrets = [
  {
    name      = "DATABASE_PASSWORD"
    valueFrom = "arn:aws:secretsmanager:..."  # ← Secure!
  }
]
```

**Why?**

- Secrets in code can be accidentally committed to Git
- AWS Secrets Manager encrypts and rotates passwords automatically
- You can audit who accessed secrets

### 5. Network Security (Private vs Public)

**Simple concept:**

- **Public subnet** = Accessible from the internet (like a storefront)
- **Private subnet** = Not accessible from internet (like a back office)

**Best Practice:**

- Put load balancers in public subnets (they need internet access)
- Put application servers in private subnets (more secure)
- Put databases in private subnets (most secure)

---

## 📝 Variable Management

### What are Variables?

Variables are like settings in a video game - they let you configure how things work without changing the code.

### Variable Types (Simple Explanation)

| Type     | What It Holds   | Example                     |
| -------- | --------------- | --------------------------- |
| `string` | Text            | `"production"`              |
| `number` | A number        | `2` or `10.5`               |
| `bool`   | True or false   | `true` or `false`           |
| `list`   | A list of items | `["a", "b", "c"]`           |
| `map`    | Key-value pairs | `{name = "John", age = 30}` |

### Variable Declaration Best Practices

#### 1. Always Add Descriptions

**Why?** So other developers (or future you) understand what the variable does.

```hcl
variable "server_count" {
  description = "How many servers should we run? More servers = more capacity but higher cost"
  type        = number
  default     = 2
}
```

#### 2. Use Validation

**Why?** To prevent mistakes (like setting server count to -5).

```hcl
variable "server_count" {
  description = "Number of servers"
  type        = number

  validation {
    condition     = var.server_count > 0 && var.server_count <= 10
    error_message = "Server count must be between 1 and 10."
  }
}
```

#### 3. Mark Sensitive Variables

**Why?** So Terraform doesn't print them in logs.

```hcl
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true  # ← This hides it from logs
}
```

### Variable File Organization

We use two files for variables:

1. **`terraform.tfvars`** - Non-sensitive settings

   ```hcl
   project_name = "mobypark"
   environment  = "production"
   server_size  = "t3.medium"
   ```

2. **`secrets.tfvars`** - Sensitive information (NOT in Git!)
   ```hcl
   database_password = "super-secret-password"
   api_key = "secret-key-here"
   ```

**Why separate?**

- `terraform.tfvars` can be shared and committed to Git
- `secrets.tfvars` stays on your computer only

---

## 🏷️ Tagging Strategy

### What are Tags?

Tags are like labels you put on resources. They help you:

- Track costs (which project costs how much?)
- Organize resources (which resources belong to which project?)
- Automate tasks (do something to all "production" resources)

### Standard Tags We Use

```hcl
locals {
  common_tags = {
    Environment = var.environment    # staging or production
    Project     = var.project_name   # Which project
    Client      = var.client_name    # Which client
    ManagedBy   = "terraform"       # How it was created
    CreatedAt   = timestamp()       # When it was created
  }
}
```

### Why Tags Matter

**Cost Tracking Example:**

- "How much does the MobyPark project cost?"
- Tags make it easy to filter and see costs per project

**Automation Example:**

- "Shut down all staging resources on weekends"
- Tags make it easy to find all staging resources

### Tagging Best Practice

**Always apply tags to every resource:**

```hcl
# Tags are automatically applied to all resources
provider "aws" {
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}
```

---

## 🔄 Version Control

### Why Pin Versions?

**Simple explanation:** Just like you might say "I need Node.js version 18", we say "I need Terraform version 1.0+".

**Why?**

- Different versions might work differently
- Pinning versions ensures everyone uses the same version
- Prevents "it works on my machine" problems

### Version Constraints Explained

```hcl
terraform {
  required_version = ">= 1.0"  # Must be version 1.0 or higher

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Version 5.0, 5.1, 5.2, etc. (but not 6.0)
    }
  }
}
```

**Version symbols:**

- `>= 1.0` = Version 1.0 or higher
- `~> 5.0` = Version 5.0, 5.1, 5.2... but not 6.0 (allows minor updates)
- `= 5.0.0` = Exactly version 5.0.0 (no updates allowed)

### Git Best Practices

#### What to Commit ✅

- ✅ All `.tf` files (Terraform code)
- ✅ `terraform.tfvars.example` (template files)
- ✅ Documentation (README files)
- ✅ Configuration files (`.checkov.yml`, `tfsec.yml`)

#### What NOT to Commit ❌

- ❌ `*.tfstate` files (state files)
- ❌ `*.tfvars` files (especially `secrets.tfvars`)
- ❌ `.terraform/` directory (downloaded providers)
- ❌ SSH keys (`key-pairs/privkey`)

**Why?** These files contain sensitive information or are generated automatically.

---

## 🔍 Security Scanning

### What is Security Scanning?

Security scanning is like having a spell-checker for security issues. It automatically finds potential security problems in your Terraform code.

### Tools We Use

1. **tfsec** - Finds security issues in Terraform code
2. **checkov** - Another security scanner (double-check)

### How to Use

```bash
# Run both scanners
task security:scan

# Or run individually
task security:tfsec
task security:checkov
```

### What to Do with Results

1. **High/Critical issues** → Fix immediately
2. **Medium issues** → Fix soon
3. **Low issues** → Fix when convenient

**Think of it like:**

- Critical = Your house is on fire (fix now!)
- High = Your door is unlocked (fix soon)
- Medium = Your window is slightly open (fix when you can)
- Low = Minor cosmetic issue (fix if you have time)

---

## ⚙️ Daily Workflows

### Common Tasks You'll Do

#### 1. Setting Up a New Project

```bash
# 1. Clone the repository
git clone <repository-url>
cd terraform-infrastructure

# 2. Decrypt SSH keys (if needed)
task key-pairs:decrypt

# 3. Initialize Terraform (downloads providers)
task infra:init
```

#### 2. Making Changes to Infrastructure

```bash
# 1. Navigate to your project
cd projects/mobypark/environments/staging

# 2. Plan your changes (preview what will happen)
task infra:plan -- mobypark/staging

# 3. Review the plan carefully!

# 4. Apply changes (actually make the changes)
task infra:apply -- mobypark/staging
```

**Think of it like:**

- `plan` = Preview mode (see what would change)
- `apply` = Actually make the changes

#### 3. Checking Security

```bash
# Run security scans before committing
task security:scan
```

#### 4. Viewing What Was Created

```bash
# After applying, see the outputs
cd projects/mobypark/environments/production
terraform output
```

This shows you important information like:

- Website URLs
- Database endpoints
- Resource IDs

### Workflow Best Practices

1. **Always plan before applying**

   - See what will change
   - Catch mistakes before they happen

2. **Test in staging first**

   - Make changes in staging
   - Verify they work
   - Then apply to production

3. **Run security scans**

   - Before committing code
   - Before applying to production

4. **Review the plan output**
   - Make sure you understand what will change
   - Look for unexpected deletions or creations

---

## 🎯 Common Patterns Explained

### Pattern 1: Multi-Service Setup (Backend + Frontend)

**What it does:** Runs multiple services (like your API and your website) in the same cluster.

**Real-world analogy:** Like having multiple apps running on the same phone.

**Example:**

```hcl
# Backend API service
module "backend_service" {
  source = "../../../../modules/compute/ecs-service"
  service_name = "mobypark-backend"
  # ... configuration
}

# Frontend website service
module "frontend_service" {
  source = "../../../../modules/compute/ecs-service"
  service_name = "mobypark-frontend"
  # ... configuration
}
```

**Why this pattern?**

- Share resources (same cluster)
- Easier to manage
- Lower cost

### Pattern 2: Load Balancer with SSL

**What it does:**

- Redirects HTTP to HTTPS (forces secure connections)
- Terminates SSL at the load balancer (handles certificates)

**Real-world analogy:** Like a security guard that checks IDs and redirects people to the secure entrance.

**Why this pattern?**

- Security (all traffic is encrypted)
- User experience (automatic redirect from http:// to https://)
- Centralized certificate management

### Pattern 3: Private Network Setup

**What it does:** Creates a private network where:

- Load balancers are public (internet can reach them)
- Application servers are private (no direct internet access)
- Databases are private (most secure)

**Real-world analogy:**

- Public subnet = Storefront (customers can enter)
- Private subnet = Back office (employees only)

**Why this pattern?**

- Security (servers not directly exposed to internet)
- Defense in depth (multiple layers of security)

### Pattern 4: Auto-Scaling

**What it does:** Automatically adds or removes servers based on demand.

**Real-world analogy:** Like a restaurant that automatically hires more waiters when it gets busy.

**Example:**

```hcl
min_size         = 2   # Always have at least 2 servers
max_size         = 20  # Never have more than 20 servers
desired_capacity = 2   # Start with 2 servers
```

**Why this pattern?**

- Handles traffic spikes automatically
- Saves money (scales down when not busy)
- Maintains performance

---

## 📖 Quick Reference Guide

### File Cheat Sheet

| File               | Purpose                | When to Edit             |
| ------------------ | ---------------------- | ------------------------ |
| `main.tf`          | Defines infrastructure | Adding new services      |
| `variables.tf`     | Lists all settings     | Adding new options       |
| `outputs.tf`       | Shows important info   | Exposing new information |
| `terraform.tfvars` | Your actual settings   | Changing configuration   |
| `secrets.tfvars`   | Passwords (secret!)    | Updating credentials     |

### Common Commands

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output

# Format code
terraform fmt

# Validate code
terraform validate

# Using Taskfile (easier!)
task infra:plan -- project/environment
task infra:apply -- project/environment
task security:scan
```

### Common Variables

```hcl
# Project identification
project_name = "mobypark"
environment  = "production"  # or "staging"

# Server configuration
server_size  = "t3.small"     # Server power level
server_count = 2              # How many servers

# Network configuration
vpc_cidr = "10.10.0.0/16"    # Private network range
```

### Security Checklist

Before applying to production:

- [ ] Ran `terraform plan` and reviewed output
- [ ] Ran security scans (`task security:scan`)
- [ ] Tested changes in staging first
- [ ] Verified no secrets in code
- [ ] Checked that encryption is enabled
- [ ] Confirmed correct environment (not applying staging to production!)

### Getting Help

1. **Check the code** - Look at similar projects for examples
2. **Read the documentation** - Each module should have a README
3. **Ask the team** - Infrastructure questions go to DevOps team
4. **Check Terraform docs** - [terraform.io/docs](https://terraform.io/docs)

---

## ✅ Checklist for New Projects

### Initial Setup

- [ ] Created project directory structure
- [ ] Set up remote state (S3 backend)
- [ ] Created `variables.tf` with all needed variables
- [ ] Created `outputs.tf` for important information
- [ ] Created `terraform.tfvars.example` template
- [ ] Added `secrets.tfvars` to `.gitignore`
- [ ] Wrote README with project overview

### Security

- [ ] Configured IAM roles (minimal permissions)
- [ ] Set up security groups (only needed ports)
- [ ] Enabled encryption (all storage)
- [ ] Set up SSL certificates
- [ ] Configured secrets management
- [ ] Ran security scans
- [ ] Fixed all high/critical security issues

### Infrastructure

- [ ] Created VPC (private network)
- [ ] Set up load balancer with SSL
- [ ] Configured ECS cluster
- [ ] Deployed services
- [ ] Set up logging (CloudWatch)
- [ ] Configured health checks
- [ ] Tested failover (what happens if a server dies?)

### Documentation

- [ ] Documented all variables
- [ ] Documented all outputs
- [ ] Created deployment guide
- [ ] Added inline comments for complex code
- [ ] Documented architecture decisions

---

## 🚨 Common Mistakes to Avoid

### 1. Committing Secrets

❌ **DON'T:**

```hcl
# In terraform.tfvars (committed to Git)
database_password = "my-secret-password"
```

✅ **DO:**

```hcl
# In secrets.tfvars (NOT in Git)
database_password = "my-secret-password"

# Or use AWS Secrets Manager
secrets = [
  {
    name      = "DATABASE_PASSWORD"
    valueFrom = "arn:aws:secretsmanager:..."
  }
]
```

### 2. Applying to Wrong Environment

❌ **DON'T:** Apply staging changes to production by accident

✅ **DO:**

- Double-check which environment you're in
- Use different AWS profiles/accounts for staging and production
- Review the plan output carefully

### 3. Not Planning First

❌ **DON'T:** Run `terraform apply` without running `terraform plan` first

✅ **DO:**

- Always run `terraform plan` first
- Review what will change
- Make sure you understand the changes

### 4. Hardcoding Values

❌ **DON'T:**

```hcl
name = "mobypark-production"  # Hardcoded!
```

✅ **DO:**

```hcl
name = "${var.project_name}-${var.environment}"  # Configurable!
```

### 5. Ignoring Security Scans

❌ **DON'T:** Ignore security scan warnings

✅ **DO:**

- Run security scans regularly
- Fix high and critical issues immediately
- Document why you're ignoring low-priority issues (if any)

---

## 📚 Additional Resources

### Internal Documentation

- [Complete ECS Example](./COMPLETE_ECS_EXAMPLE.md) - Full working example
- [Usage Examples](./USAGE_EXAMPLE.md) - How to use common patterns
- [Migration Plan](./MIGRATION_PLAN.md) - How to migrate existing infrastructure

### Learning Resources

- **Terraform Basics:** [Terraform Learn](https://learn.hashicorp.com/terraform)
- **AWS Concepts:** [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- **Security:** [tfsec Documentation](https://aquasecurity.github.io/tfsec/)

### Getting Help

- **Infrastructure Team:** For Terraform and AWS questions
- **DevOps Lead:** For architecture decisions
- **Security Team:** For security-related questions

---

## 💡 Tips for Non-Cloud Engineers

### Start Small

Don't try to understand everything at once. Start with:

1. Understanding what `main.tf` does
2. Learning how to read `variables.tf`
3. Running `terraform plan` to see what changes

### Use Examples

Look at existing projects (like `mobypark`) to see how things are done. Copy patterns that work.

### Ask Questions

There's no such thing as a stupid question. If something doesn't make sense, ask!

### Test in Staging

Always test changes in staging first. Staging is your safe playground.

### Read the Plan Output

The `terraform plan` output tells you exactly what will change. Read it carefully before applying.

---

## 📝 Document Maintenance

This document should be updated:

- **When new patterns are adopted** - Add examples
- **When tools change** - Update instructions
- **When common mistakes are discovered** - Add to pitfalls section
- **Quarterly** - Review and refresh content

**Contributors:** Infrastructure Team  
**Reviewers:** DevOps Lead, Security Team

---

_Last updated: 2024_

**Remember:** Infrastructure as Code is just code. If you can write application code, you can understand Terraform! 🚀
