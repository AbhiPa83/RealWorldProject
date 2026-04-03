# Pre-Deployment and Post-Deployment Checklist

## Pre-Deployment Checklist

### Prerequisites (5 minutes)
- [ ] Terraform installed (`terraform --version`)
- [ ] AWS CLI installed (`aws --version`)
- [ ] AWS credentials configured (`aws configure`)
- [ ] Access to AWS account with appropriate permissions
- [ ] Text editor to modify files (nano, vim, VSCode, etc.)

### AWS Account Setup (10 minutes)
- [ ] Create EC2 Key Pair in ap-south-1 region
  ```bash
  aws ec2 create-key-pair --key-name my-app-key --region ap-south-1 --query 'KeyMaterial' --output text > ~/.ssh/my-app-key.pem
  chmod 400 ~/.ssh/my-app-key.pem
  ```
- [ ] Note the key pair name for configuration
- [ ] Verify key pair exists: `aws ec2 describe-key-pairs --region ap-south-1`
- [ ] Check AWS quotas for EC2 instances (minimum 6 vCPUs recommended)

### Configuration Review (5 minutes)
- [ ] Open `terraform.tfvars`
- [ ] Update `key_pair_name` to match your EC2 key pair
- [ ] Update `db_password` to a strong password:
  - At least 8 characters long
  - Contains uppercase letters (A-Z)
  - Contains lowercase letters (a-z)
  - Contains numbers (0-9)
  - Contains special characters (!@#$%^&*)
  - Example: `MySecureP@ssw0rd`
- [ ] Review other variables (region, instance types, etc.)
- [ ] Ensure file looks valid (no syntax errors)

### Documentation Review (3 minutes)
- [ ] Skim through README.md to understand the architecture
- [ ] Review QUICKSTART.md for deployment steps
- [ ] Check ARCHITECTURE.md for detailed infrastructure design
- [ ] Understand the security group configuration

### Pre-Flight Check (5 minutes)
```bash
# Navigate to project directory
cd /home/linux/projects/RealWorldProject

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Check output (should succeed)
echo "✓ Validation passed"

# Plan changes (review before applying)
terraform plan -out=tfplan
```

- [ ] Terraform init completed successfully
- [ ] Terraform validate shows no errors
- [ ] Terraform plan shows expected resources (~25 resources)
- [ ] Plan output saved to tfplan

---

## Deployment Checklist

### During Deployment (15 minutes)
- [ ] Run: `terraform apply tfplan`
- [ ] Wait for completion (status should show "Apply complete!")
- [ ] Note the outputs (ALB DNS, Bastion IP, RDS endpoint)
- [ ] Do NOT interrupt the process

### Monitoring Deployment (10 minutes after apply)
```bash
# View all outputs
terraform output

# Check specific values
ALB_DNS=$(terraform output -raw alb_dns_name)
BASTION_IP=$(terraform output -raw bastion_public_ip)
```

- [ ] Note ALB DNS name (e.g., app-alb-123456789.ap-south-1.elb.amazonaws.com)
- [ ] Note Bastion Public IP
- [ ] Note RDS Endpoint

---

## Post-Deployment Checklist

### Immediate Verification (5 minutes)

#### 1. Check Infrastructure Status
```bash
# Verify EC2 instances
aws ec2 describe-instances --region ap-south-1 --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].[InstanceId,InstanceType]' --output table

# Verify ALB
aws elbv2 describe-load-balancers --region ap-south-1 --query 'LoadBalancers[*].[LoadBalancerName,State.Code]' --output table

# Verify RDS
aws rds describe-db-instances --region ap-south-1 --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]' --output table
```

- [ ] 3 EC2 instances are running (ASG instances)
- [ ] 1 Bastion instance is running
- [ ] ALB is in active state
- [ ] RDS database is available

#### 2. Check ALB Target Group Health
```bash
# Get target group ARN
TG_ARN=$(terraform output -raw target_group_arn)

# Check health
aws elbv2 describe-target-health --target-group-arn $TG_ARN --region ap-south-1 --output table
```

- [ ] All targets are showing "healthy" status
- [ ] If not healthy, wait 3-5 minutes and check again
- [ ] Healthy threshold should be 2/2

#### 3. Test Application Access
```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Test with curl
curl http://$ALB_DNS

# Or open in browser
echo "http://$ALB_DNS"
```

- [ ] Can access application via ALB DNS name
- [ ] Get HTML response with "Welcome to the Application Server"
- [ ] Hostname shows one of the running instances

### After 5-10 Minutes

#### 4. Verify Bastion Access
```bash
# Get Bastion IP
BASTION_IP=$(terraform output -raw bastion_public_ip)

# Test SSH
ssh -i ~/.ssh/my-app-key.pem ec2-user@$BASTION_IP

# Inside Bastion, check date
date
exit
```

- [ ] Can SSH to Bastion Host
- [ ] SSH connection established successfully
- [ ] Exit command works properly

#### 5. Database Connectivity Test (Optional)
```bash
# SSH to Bastion first
BASTION_IP=$(terraform output -raw bastion_public_ip)
ssh -i ~/.ssh/my-app-key.pem ec2-user@$BASTION_IP

# From Bastion, get RDS endpoint
RDS_ENDPOINT=$(aws rds describe-db-instances --region ap-south-1 --query 'DBInstances[0].Endpoint.Address' --output text)

# Test MySQL connection
mysql -h $RDS_ENDPOINT -u admin -p
# Enter password: (your db_password from terraform.tfvars)
# Type: SHOW DATABASES;
# Type: EXIT;
```

- [ ] MySQL client connects to RDS
- [ ] Can execute SQL commands
- [ ] Database is operational

#### 6. Check Instance Configuration
```bash
# SSH to Bastion
BASTION_IP=$(terraform output -raw bastion_public_ip)
ssh -i ~/.ssh/my-app-key.pem ec2-user@$BASTION_IP

# Check httpd status
sudo systemctl status httpd

# Check user_data log
tail -f /var/log/user_data.log

# Check httpd is serving
curl http://localhost

# Check MySQL client
mysql --version

# Exit Bastion
exit
```

- [ ] httpd service is running
- [ ] user_data script completed successfully
- [ ] Can curl localhost and get HTML response
- [ ] MySQL client is installed

#### 7. Monitor Auto Scaling
```bash
# Check ASG details
aws autoscaling describe-auto-scaling-groups --region ap-south-1 --query 'AutoScalingGroups[*].[AutoScalingGroupName,MinSize,MaxSize,DesiredCapacity,Instances[].InstanceId]' --output table

# List all EC2 instances
aws ec2 describe-instances --region ap-south-1 --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PrivateIpAddress]' --output table
```

- [ ] ASG has 3 instances (desired capacity = 3)
- [ ] Min size = 3, Max size = 6
- [ ] All instances are running
- [ ] 1 Bastion + 3 ASG instances = 4 total

### After 30 Minutes

#### 8. Verify CloudWatch Metrics
```bash
# Get Auto Scaling Group name
ASG_NAME=$(terraform output -raw asg_name)

# Check CloudWatch alarms
aws cloudwatch describe-alarms --region ap-south-1 --query 'MetricAlarms[?contains(AlarmName, `app-`)].{Name:AlarmName,State:StateValue}' --output table
```

- [ ] Both scaling alarms are in OK state
- [ ] No alarms are in ALARM state
- [ ] Health check metrics are available

#### 9. Test Load Balancing
```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)

# Make multiple requests to see different hostnames
for i in {1..5}; do
  echo "Request $i:"
  curl -s http://$ALB_DNS | grep "Hostname:"
done
```

- [ ] Hostname changes across requests (shows load balancing)
- [ ] All responses are successful (HTTP 200)
- [ ] Different instances serve different requests

### After 1 Hour

#### 10. Long-Running Stability Check
```bash
# Check if instances are still healthy
aws ec2 describe-instances --region ap-south-1 --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[].[InstanceId,State.Name,InstanceType]' --output table

# Check ALB target health again
TG_ARN=$(terraform output -raw target_group_arn)
aws elbv2 describe-target-health --target-group-arn $TG_ARN --region ap-south-1 --output table

# Check RDS status
aws rds describe-db-instances --region ap-south-1 --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,BackupRetentionPeriod]' --output table
```

- [ ] All instances still running
- [ ] All targets still healthy
- [ ] RDS still available
- [ ] No unexpected state changes

---

## Troubleshooting Checklist

### If EC2 Instances Not Healthy

- [ ] Wait 5-10 minutes (health checks need time)
- [ ] Check user_data log: SSH to instance → `tail /var/log/user_data.log`
- [ ] Verify httpd is running: `sudo systemctl status httpd`
- [ ] Check security group: `sudo iptables -L` or check AWS console
- [ ] Review httpd logs: `sudo tail -f /var/log/httpd/error_log`
- [ ] If issues persist: `terraform destroy` and redeploy

### If Cannot SSH to Bastion
- [ ] Verify key pair file exists: `ls -la ~/.ssh/my-app-key.pem`
- [ ] Check key permissions: `ls -l ~/.ssh/my-app-key.pem` (should be 400)
- [ ] Verify security group allows SSH: `aws ec2 describe-security-groups --group-ids <sg-id>`
- [ ] Check Bastion IP: `terraform output bastion_public_ip`
- [ ] Test ping: `ping <bastion_ip>`

### If Database Connection Fails
- [ ] Verify RDS is available: `aws rds describe-db-instances --region ap-south-1`
- [ ] Check security group: MySQL SG should allow EC2 SG
- [ ] Test from EC2 instance (not Bastion directly)
- [ ] Verify credentials: username=admin, password=your_db_password
- [ ] Check MySQL client installed: `mysql --version`

### If ALB Not Responding
- [ ] Check ALB status: `aws elbv2 describe-load-balancers --region ap-south-1`
- [ ] Verify target group has healthy targets
- [ ] Check security group allows inbound 80 from 0.0.0.0/0
- [ ] Wait 10-15 minutes for full initialization
- [ ] Review ALB access logs (enable in AWS console)

### If Scaling Not Working
- [ ] Check CloudWatch alarms: `aws cloudwatch describe-alarms --region ap-south-1`
- [ ] Review ASG activity: `aws autoscaling describe-scaling-activities --auto-scaling-group-name <asg-name>`
- [ ] Launch template error: Check latest version
- [ ] Verify quota not exceeded: `aws service-quotas list-service-quotas --service-code ec2`

---

## Post-Deployment Recommendations

### Security Hardening
- [ ] Restrict Bastion SSH to specific IPs (not 0.0.0.0/0)
- [ ] Enable VPC Flow Logs for network monitoring
- [ ] Set up CloudWatch alarms for suspicious activity
- [ ] Enable bucket versioning for Terraform state (S3)
- [ ] Rotate database password regularly

### Monitoring & Logging
- [ ] Enable CloudWatch detailed monitoring (costs apply)
- [ ] Set up SNS topics for alarm notifications
- [ ] Enable RDS enhanced monitoring
- [ ] Configure application-level logging
- [ ] Set up cost monitoring budget alerts

### High Availability
- [ ] Enable ALB stickiness if needed
- [ ] Configure RDS read replicas for reporting
- [ ] Set up automated snapshots
- [ ] Enable VPC endpoint for private S3 access
- [ ] Configure backup retention policy

### Performance Optimization
- [ ] Add CloudFront for static content
- [ ] Implement caching (ElastiCache)
- [ ] Optimize database indices
- [ ] Configure auto-scaling based on custom metrics
- [ ] Implement request throttling

### Cost Optimization
- [ ] Review CloudWatch billing (free tier usage)
- [ ] Consider Reserved Instances for stable workloads
- [ ] Use Spot Instances for non-critical components
- [ ] Set up AWS Budget alerts
- [ ] Implement tagging strategy for cost allocation

---

## Maintenance Checklist

### Weekly
- [ ] Review CloudWatch metrics and alarms
- [ ] Check RDS backup completion
- [ ] Monitor application logs
- [ ] Verify security group rules are still appropriate

### Monthly
- [ ] Review AWS costs
- [ ] Check for AWS service updates
- [ ] Test disaster recovery procedures
- [ ] Rotate database password if not using Secrets Manager

### Quarterly
- [ ] Full security audit
- [ ] Performance optimization review
- [ ] Update instance AMI to latest patch level
- [ ] Review and update Terraform modules

### Annually
- [ ] Disaster recovery drill
- [ ] Complete backup/restore test
- [ ] architectural review
- [ ] Re-assess infrastructure needs

---

## Final Verification Summary

After all checks pass, you should have:

✅ Fully operational VPC with public/private subnets
✅ 3-6 auto-scaling EC2 instances running httpd
✅ Bastion host for secure SSH access
✅ Application Load Balancer distributing traffic
✅ RDS MySQL database with Multi-AZ
✅ All security groups properly configured
✅ Auto-scaling based on CPU metrics
✅ Application accessible via ALB DNS name
✅ Database accessible from EC2 instances
✅ Monitoring and alarms in place

**Estimated Monthly Cost**: $15-25 (with free tier)

---

**Congratulations! Your infrastructure is production-ready.** 🚀
