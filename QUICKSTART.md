# Quick Start Guide

This guide will help you deploy the infrastructure in 15 minutes.

## Step 1: Prerequisites (2 minutes)

### Install Terraform
```bash
# On macOS
brew install terraform

# On Linux (Ubuntu/Debian)
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# On Windows
choco install terraform
```

### Install AWS CLI
```bash
# On macOS
brew install awscli

# On Linux
sudo apt-get install awscli

# On Windows
choco install awscli
```

### Configure AWS Credentials
```bash
aws configure

# Enter your AWS Access Key ID and Secret Access Key
# Default region: ap-south-1
# Default output format: json
```

## Step 2: Create EC2 Key Pair (3 minutes)

```bash
# List existing key pairs
aws ec2 describe-key-pairs --region ap-south-1

# Create a new key pair
aws ec2 create-key-pair \
  --key-name my-app-key \
  --region ap-south-1 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/my-app-key.pem

# Set permissions
chmod 400 ~/.ssh/my-app-key.pem
```

**Save this key pair safely! You'll need it to SSH into instances.**

## Step 3: Update Configuration (2 minutes)

Edit `terraform.tfvars`:

```bash
# Open the file
nano terraform.tfvars

# Change these values:
key_pair_name = "my-app-key"  # Your key pair name from Step 2
db_password = "MySecurePass@123"  # Change to a strong password

# Save and exit (Ctrl+X, then Y, then Enter)
```

## Step 4: Deploy Infrastructure (8 minutes)

```bash
# Within the project directory
cd /home/linux/projects/RealWorldProject

# Initialize Terraform
terraform init

# Preview what will be created
terraform plan -out=tfplan

# Create the infrastructure
terraform apply tfplan

# Wait for completion (typically 10-15 minutes)
```

## Step 5: Access Your Application (2 minutes)

```bash
# Get the Application URL
terraform output alb_dns_name

# Open in browser
# http://<your-alb-dns-name>

# You should see: "Welcome to the Application Server"
```

## Step 6: SSH Access (Optional)

### Access via Bastion Host

```bash
# Get Bastion IP
BASTION_IP=$(terraform output -raw bastion_public_ip)

# SSH into Bastion
ssh -i ~/.ssh/my-app-key.pem ec2-user@$BASTION_IP

# Once inside Bastion, you can SSH to private instances:
ssh -i ~/.ssh/my-app-key.pem ec2-user@<private-instance-ip>
```

## Step 7: Access Database (Optional)

```bash
# Get RDS endpoint
RDS_ENDPOINT=$(terraform output -raw rds_address)

# From an EC2 instance (via Bastion):
mysql -h $RDS_ENDPOINT -u admin -p
# Password: (enter the db_password you set in terraform.tfvars)

# Basic MySQL commands:
SHOW DATABASES;
USE appdb;
SHOW TABLES;
```

## Verify Everything is Working

### 1. Check EC2 Instances
```bash
aws ec2 describe-instances \
  --region ap-south-1 \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,PrivateIpAddress,State.Name]' \
  --output table
```

### 2. Check ALB
```bash
aws elbv2 describe-load-balancers \
  --region ap-south-1 \
  --query 'LoadBalancers[*].[LoadBalancerName,DNSName,State.Code]' \
  --output table
```

### 3. Check Auto Scaling Group
```bash
aws autoscaling describe-auto-scaling-groups \
  --region ap-south-1 \
  --query 'AutoScalingGroups[*].[AutoScalingGroupName,MinSize,MaxSize,DesiredCapacity,Instances[].InstanceId]' \
  --output table
```

### 4. Check RDS Database
```bash
aws rds describe-db-instances \
  --region ap-south-1 \
  --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,DBInstanceClass,Engine]' \
  --output table
```

### 5. Check Target Group Health
```bash
# Get target group ARN
TG_ARN=$(terraform output -raw target_group_arn)

# Check health
aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN \
  --region ap-south-1 \
  --output table
```

## Common Commands

```bash
# View all outputs
terraform output

# View specific output
terraform output alb_dns_name

# Update capacity (scale up/down)
terraform apply -var="asg_desired_capacity=5"

# Refresh state
terraform refresh

# Destroy all resources
terraform destroy
```

## Troubleshooting

### Issue: "Target registrations are not healthy"

**Solution**: Wait 5-10 minutes for health checks to pass. Check logs:
```bash
# SSH into instance
# Check user_data logs
cat /var/log/user_data.log

# Check httpd
sudo systemctl status httpd
sudo tail -f /var/log/httpd/error_log
```

### Issue: "Cannot connect to database"

**Solution**: Check security group:
```bash
# Verify from EC2 instance
telnet <rds-endpoint> 3306

# Check MySQL client is installed
mysql --version
```

### Issue: "Key pair error"

**Solution**: Verify key pair exists:
```bash
aws ec2 describe-key-pairs --region ap-south-1

# If not found, create it using Step 2 above
```

### Issue: "Terraform state lock"

**Solution**: If stuck, check for running processes:
```bash
# This should rarely happen, but if needed:
terraform force-unlock <LOCK_ID>
```

## Cleaning Up

To remove all resources and avoid charges:

```bash
terraform destroy -auto-approve
```

**WARNING**: This will:
- Terminate all EC2 instances
- Delete the RDS database
- Remove the VPC, subnets, security groups, etc.
- Delete everything EXCEPT the Key Pair

## What's Installed on EC2 Instances

The AMI used is **Amazon Linux 2** with:
- httpd (Apache Web Server)
- MySQL client
- Basic development tools
- CloudWatch agent tools
- Systems Manager agent

## File Locations on EC2

- **Application logs**: `/var/log/user_data.log`
- **Apache logs**: `/var/log/httpd/access_log` and `error_log`
- **Web root**: `/var/www/html/`
- **Configuration**: `/etc/httpd/conf/`

## Next Steps

1. ✅ Customize the HTML page: Edit `modules/ec2/user_data.sh`
2. ✅ Add SSL/TLS: Get ACM certificate and update ALB
3. ✅ Deploy your application: Update Launch Template user_data
4. ✅ Set up monitoring: Enable CloudWatch dashboards
5. ✅ Configure backups: RDS already has 7-day retention

## Support

- **Terraform Docs**: https://www.terraform.io/docs
- **AWS Docs**: https://docs.aws.amazon.com
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

## Key Metrics

After deployment, you'll have:
- ✅ 3-6 EC2 instances (auto-scaling)
- ✅ 1 Application Load Balancer
- ✅ 1 RDS MySQL database
- ✅ 2 NAT Gateways
- ✅ 1 Internet Gateway
- ✅ 6 Security Groups
- ✅ 4 Route Tables
- ✅ 5 Subnets in 2 AZs

Estimated cost (with free tier): $15-20/month

---

**Congratulations! Your infrastructure is now ready to use.** 🎉
