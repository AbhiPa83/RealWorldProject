# Infrastructure Architecture Documentation

## Overview

This document provides a detailed overview of the infrastructure created by the Terraform configuration.

## Network Architecture

### VPC Configuration
- **CIDR Block**: 192.168.0.0/16
- **Region**: ap-south-1 (Mumbai)
- **Availability Zones**: ap-south-1a, ap-south-1b

### Subnet Layout

#### Public Subnets
1. **Public Subnet AZ1** (ap-south-1a)
   - CIDR: 192.168.1.0/24
   - Contains: Bastion Host, NAT Gateway, ALB
   - Route Table: Routes traffic to Internet Gateway

2. **Public Subnet AZ2** (ap-south-1b)
   - CIDR: 192.168.2.0/24
   - Contains: NAT Gateway, ALB
   - Route Table: Routes traffic to Internet Gateway

#### Private Subnets
1. **Private Subnet AZ1** (ap-south-1a)
   - CIDR: 192.168.3.0/24
   - Contains: EC2 instances from ASG
   - Route Table: Routes outbound traffic through NAT Gateway in AZ1

2. **Private Subnet AZ2** (ap-south-1b)
   - CIDR: 192.168.4.0/24
   - Contains: EC2 instances from ASG
   - Route Table: Routes outbound traffic through NAT Gateway in AZ2

#### Database Subnet
1. **Database Subnet** (ap-south-1a)
   - CIDR: 192.168.5.0/24
   - Contains: RDS MySQL instance
   - Route Table: No internet access (database only)

### Network Flow

```
Internet
   ↓
Internet Gateway (IGW)
   ↓
ALB (Public Subnets)
   ↓
Target Group
   ↓
ASG Instances (Private Subnets)
   ↓
NAT Gateway (for outbound traffic)
   ↓
Internet
```

## Security Groups

### 1. Bastion Security Group
- **Inbound Rules**:
  - SSH (port 22) from 0.0.0.0/0 (anywhere)
- **Outbound Rules**:
  - All traffic allowed

### 2. ALB Security Group
- **Inbound Rules**:
  - HTTP (port 80) from 0.0.0.0/0
  - HTTPS (port 443) from 0.0.0.0/0 (optional, requires SSL certificate)
- **Outbound Rules**:
  - All traffic allowed

### 3. EC2 Security Group
- **Inbound Rules**:
  - HTTP (port 80) from ALB Security Group
  - HTTPS (port 443) from ALB Security Group
  - SSH (port 22) from Bastion Security Group
  - MySQL (port 3306) from EC2 Security Group (for multi-instance communication)
- **Outbound Rules**:
  - All traffic allowed

### 4. MySQL Security Group
- **Inbound Rules**:
  - MySQL (port 3306) from EC2 Security Group only
- **Outbound Rules**:
  - All traffic allowed

## Compute Resources

### Bastion Host
- **Instance Type**: t3.micro
- **Location**: Public Subnet AZ1
- **Purpose**: Secure gateway for SSH access to private instances
- **AMI**: Amazon Linux 2
- **Elastic IP**: Yes (static public IP)
- **Security**: Only accessible via SSH

### Auto Scaling Group
- **Desired Capacity**: 3 instances
- **Min Size**: 3 instances
- **Max Size**: 6 instances
- **Instance Type**: t3.micro
- **Location**: Private Subnets (AZ1 and AZ2)
- **Launch Template**: Custom template with user_data script
- **Health Check Type**: ELB
- **Health Check Grace Period**: 300 seconds

### User Data Script
The EC2 instances automatically run a script that:
1. Updates all system packages
2. Installs Apache HTTP Server (httpd)
3. Installs MySQL client tools
4. Creates a simple web page for health checks
5. Configures MySQL connectivity (if RDS endpoint provided)

## Load Balancing

### Application Load Balancer
- **Name**: app-alb
- **Scheme**: Internet-facing
- **IP Address Type**: IPv4
- **Subnets**: Public Subnets in AZ1 and AZ2
- **Security Group**: ALB Security Group
- **DNS Name**: Auto-generated (outputs as `alb_dns_name`)

### Target Group
- **Name**: app-tg
- **Protocol**: HTTP (port 80)
- **Target Type**: EC2 instances
- **Health Check**:
  - Protocol: HTTP
  - Path: /
  - Port: 80
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Healthy Threshold: 2
  - Unhealthy Threshold: 2

### Listener
- **Port**: 80
- **Protocol**: HTTP
- **Action**: Forward to target group

## Database

### RDS MySQL Instance
- **Engine**: MySQL 8.0
- **Instance Class**: db.t3.micro
- **Storage**: 20 GB (gp3)
- **Storage Encryption**: Yes (enabled)
- **Multi-AZ**: Yes (for high availability)
- **Public Accessibility**: No (only accessible from EC2 instances)
- **Security Group**: MySQL SG (only accepts connections from EC2 instances)
- **Backup Retention**: 7 days
- **Backup Window**: 03:00-04:00 UTC
- **Maintenance Window**: Sunday 04:00-05:00 UTC
- **Deletion Protection**: Enabled

### Database Subnet Group
- **Subnets**: Database subnet
- **Multi-AZ Support**: Single subnet (configured for single AZ)

## Auto Scaling Configuration

### Scaling Policies

#### Scale Up Policy
- **Trigger**: CPU utilization > 70% for 2 consecutive periods
- **Cooldown**: 5 minutes
- **Action**: Add 1 instance

#### Scale Down Policy
- **Trigger**: CPU utilization < 30% for 2 consecutive periods
- **Cooldown**: 5 minutes
- **Action**: Remove 1 instance

### CloudWatch Alarms
1. **High CPU Alarm**: Triggers if average CPU > 70%
2. **Low CPU Alarm**: Triggers if average CPU < 30%

## IAM Configuration

### EC2 Instance Profile
- **Role**: ec2-app-role
- **Attached Policies**:
  - CloudWatchAgentServerPolicy (for CloudWatch monitoring)
  - AmazonSSMManagedInstanceCore (for Systems Manager access)

## Traffic Flow Examples

### Example 1: User Accessing the Application
1. User sends HTTP request to ALB DNS name
2. ALB receives request on port 80 (HTTP)
3. ALB checks target group health
4. ALB forwards request to healthy EC2 instance
5. EC2 instance receives request and serves web page via httpd
6. Response sent back through ALB to user

### Example 2: Database Access
1. Application on EC2 instance connects to RDS endpoint
2. Connection request passes through EC2 security group (egress)
3. MySQL security group accepts connection (inbound from EC2 SG)
4. RDS MySQL processes query and returns result
5. Application receives data

### Example 3: SSH Access to Private Instance
1. User connects to Bastion Host using key pair
2. User SSH from Bastion to private instance (using private IP)
3. SSH connection passes through EC2 security group (from Bastion SG)
4. User gains terminal access to private instance

## High Availability Features

1. **Multi-AZ Deployment**:
   - Instances spread across 2 availability zones
   - NAT Gateway in each AZ for redundancy
   - ALB in multiple AZs for fault tolerance

2. **RDS Multi-AZ**:
   - Synchronous replication to standby instance
   - Automatic failover in case of failure
   - Enhanced availability and durability

3. **Auto Scaling**:
   - Automatically launches replacement instances
   - Responds to load changes
   - Maintains desired capacity

4. **Load Balancing**:
   - Distributes traffic across multiple instances
   - Health checks detect unhealthy instances
   - Automatic removal of unhealthy targets

## Disaster Recovery

### Backup Strategy
- **Database**: 7-day retention automated backups
- **Application**: Stateless (can be redeployed quickly)
- **Configuration**: Stored in Terraform code

### Recovery Time Objective (RTO)
- **Application**: < 5 minutes (via ASG recovery)
- **Database**: < 2 minutes (via RDS failover)
- **Entire Infrastructure**: < 15 minutes (via Terraform)

## Cost Optimization

### Current Configuration
- **Free Tier Eligible**: Yes (t3.micro, db.t3.micro)
- **Estimated Monthly Cost**: ~$15-20 (with free tier applicable)

### For Production, Consider:
1. Using larger instance types for performance
2. Reserved instances for better pricing
3. S3 for static content (offload from httpd)
4. CloudFront for global distribution
5. ElastiCache for application caching

## Monitoring and Logging

### CloudWatch Metrics
- CPU Utilization
- Network In/Out
- Disk I/O
- RDS Metrics

### Available Logs
- Application logs: `/var/log/user_data.log` on EC2 instances
- Access logs: Apache httpd logs in `/var/log/httpd/`
- Database logs: RDS logs in AWS console

## Security Best Practices Implemented

1. ✅ Private subnets for application servers
2. ✅ Bastion host for secure SSH access
3. ✅ Security groups with least privilege access
4. ✅ Database not accessible from internet
5. ✅ RDS encryption at rest
6. ✅ Multi-AZ for availability
7. ✅ Deletion protection on RDS
8. ✅ NATGateway for outbound internet access

## Future Enhancements

1. **SSL/TLS**: Add HTTPS with ACM certificate and ALB HTTPS listener
2. **Auto Scaling Groups**: Use Target Tracking policies for better scaling
3. **Monitoring**: Add CloudWatch dashboards and SNS alerts
4. **Logging**: Centralize logs in CloudWatch Logs or ELK Stack
5. **CI/CD**: Integrate with CodeDeploy/CodePipeline for automated deployments
6. **Database Replication**: Set up read replicas for reporting
7. **Caching**: Add ElastiCache for improved performance
8. **WAF**: Add AWS WAF for DDoS protection and vulnerability scanning

## Terraform Modules

Each module is self-contained with its own:
- `main.tf`: Resource definitions
- `variables.tf`: Input variables
- `outputs.tf`: Output values

### Module Dependencies
```
Root Module
├── VPC Module (no dependencies)
├── Security Groups Module (depends on VPC)
├── EC2 Module (depends on Security Groups, VPC)
├── ALB Module (depends on VPC, Security Groups)
├── Auto Scaling Module (depends on EC2, ALB)
└── RDS Module (depends on VPC, Security Groups)
```

## Commands Reference

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# View outputs
terraform output

# Destroy infrastructure
terraform destroy

# State management
terraform state list
terraform state show module.vpc
terraform refresh
```

## Troubleshooting

### Check Application Status
```bash
# Connect to Bastion
ssh -i key.pem ec2-user@<bastion-ip>

# From Bastion, check instance status
aws ec2 describe-instances --region ap-south-1

# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <tg-arn>
```

### Database Connectivity
```bash
# From EC2 instance
mysql -h <rds-endpoint> -u admin -p

# Check security group rules
aws ec2 describe-security-groups --group-ids <mysql-sg-id>
```

### Logs
```bash
# Application initialization
tail -f /var/log/user_data.log

# Apache web server
tail -f /var/log/httpd/access_log
tail -f /var/log/httpd/error_log
```
