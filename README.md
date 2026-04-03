# Real World Project - Terraform Infrastructure

This Terraform project creates a production-ready AWS infrastructure with:
- VPC with public and private subnets across 2 Availability Zones
- Bastion Host for secure SSH access
- Application Load Balancer (ALB)
- Auto Scaling Group with EC2 instances (3-6 instances)
- RDS MySQL Database
- Security Groups for all components

## Architecture

The infrastructure consists of:

1. **VPC**: 192.168.0.0/16 with multiple subnets
2. **Public Subnets**: For Bastion Host and ALB (2 AZs)
3. **Private Subnets**: For application servers (2 AZs)
4. **Database Subnet**: For RDS MySQL instance
5. **Auto Scaling Group**: Automatically scales between 3-6 instances
6. **Application Load Balancer**: Distributes traffic to instances
7. **RDS MySQL**: Multi-AZ database with automated backups
8. **Security Groups**: Configured for secure communication

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- An EC2 Key Pair already created in your AWS account

## Setup Instructions

### 1. Create an EC2 Key Pair (if not already done)

```bash
aws ec2 create-key-pair --key-name my-key-pair --region ap-south-1 --query 'KeyMaterial' --output text > my-key-pair.pem
chmod 400 my-key-pair.pem
```

### 2. Update Configuration

Edit `terraform.tfvars` and set:
- `key_pair_name`: Name of your EC2 Key Pair
- `db_password`: Change to a strong password (min 8 characters, include uppercase, lowercase, numbers, special characters)
- Other variables as needed

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan the Infrastructure

```bash
terraform plan -out=tfplan
```

### 5. Apply the Configuration

```bash
terraform apply tfplan
```

This will create all the AWS resources. The process typically takes 10-15 minutes.

## User Data Script

The EC2 instances (launched via Auto Scaling Group) automatically run a user_data script that:
- Updates the system packages
- Installs Apache HTTP Server (httpd)
- Installs MySQL client tools
- Creates a simple health check HTML page
- Configures MySQL client connectivity to RDS

If you want to install MySQL Server on EC2 instances (not recommended for production), uncomment the relevant lines in `modules/ec2/user_data.sh`.

## Accessing Your Application

After deployment completes, you can access your application:

```bash
# Get the ALB DNS name
terraform output alb_dns_name

# Then visit in browser
http://<alb_dns_name>
```

To SSH into the Bastion Host:

```bash
# Get the Bastion IP
terraform output bastion_public_ip

ssh -i my-key-pair.pem ec2-user@<bastion_ip>

# From Bastion, SSH to a private instance
ssh -i my-key-pair.pem ec2-user@<private_instance_ip>
```

To access the MySQL database:

```bash
# From a private instance or bastion
mysql -h <rds_endpoint> -u admin -p

# Enter the password from terraform.tfvars
```

## Project Structure

```
.
├── main.tf                 # Root main configuration
├── variables.tf            # Root variables
├── outputs.tf              # Root outputs
├── terraform.tfvars        # Variable values (IMPORTANT: Set values here)
├── modules/
│   ├── vpc/
│   │   ├── main.tf         # VPC, Subnets, NAT Gateways, Route Tables
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security_groups/
│   │   ├── main.tf         # All Security Groups
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/
│   │   ├── main.tf         # Launch Template, Bastion Host
│   │   ├── user_data.sh    # EC2 initialization script
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/
│   │   ├── main.tf         # Application Load Balancer
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── autoscaling/
│   │   ├── main.tf         # Auto Scaling Group with policies
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── rds/
│       ├── main.tf         # RDS MySQL Database
│       ├── variables.tf
│       └── outputs.tf
├── .gitignore
└── README.md               # This file
```

## Module Descriptions

### VPC Module
Creates the Virtual Private Cloud with:
- Internet Gateway
- Public and Private Subnets (2 AZs)
- NAT Gateways for private subnet internet access
- Route Tables and associations

### Security Groups Module
Defines security groups for:
- Bastion Host (SSH from anywhere)
- Application Load Balancer (HTTP/HTTPS)
- EC2 Instances (traffic from ALB and Bastion)
- MySQL Database (traffic from EC2 instances only)

### EC2 Module
Provides:
- Launch Template with user_data script
- Bastion Host instance in public subnet
- Installs httpd, MySQL client, and configures the application

### ALB Module
Creates:
- Application Load Balancer (internet-facing)
- Target Group for EC2 instances
- Listener for HTTP traffic (port 80)

### Auto Scaling Module
Sets up:
- Auto Scaling Group (3-6 instances)
- Scaling policies (scale up/down based on CPU)
- CloudWatch alarms for monitoring

### RDS Module
Configures:
- MySQL 8.0 Database
- Multi-AZ deployment for high availability
- Automated backups (7-day retention)
- Encryption at rest
- Database subnet group

## Scaling and Maintenance

### Manual Scaling

```bash
terraform apply -var="asg_desired_capacity=5"
```

### Modify Database Password

```bash
terraform apply -var='db_password=NewPassword@123'
```

### Disable Multi-AZ (not recommended for production)

```bash
terraform apply -var="rds_multi_az=false"
```

## Monitoring and Logging

- CloudWatch Metrics: CPU utilization triggers auto-scaling
- Application logs: Available in EC2 instances at `/var/log/user_data.log`
- RDS: Enable enhanced monitoring in the console

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**WARNING**: This will delete all resources including the RDS database (unless deletion_protection is true).

## Security Considerations

1. **Database Password**: Change the default password in `terraform.tfvars`
2. **SSH Access**: Bastion host accepts SSH from anywhere (0.0.0.0/0) - restrict in production
3. **Private Subnets**: Application servers are in private subnets, not directly accessible from internet
4. **RDS**: Database is in a separate subnet and only accepts connections from EC2 instances
5. **Tags**: All resources are tagged with Environment and Project for cost tracking

## Common Issues

### Issue: "InvalidKeyPair.NotFound"
**Solution**: Create the key pair using the AWS CLI command above

### Issue: "Service role is invalid or cannot be assumed"
**Solution**: Ensure IAM permissions are correct for your AWS account

### Issue: Database connection fails
**Solution**: SSH to an EC2 instance and test connectivity from there

### Issue: Terraform state issues
**Solution**: Store state remotely in S3 for team environments:
```bash
# Create a backend.tf file with S3 backend configuration
```

## Next Steps

1. Configure SSL/TLS certificates (ALB listener for HTTPS)
2. Set up CloudWatch dashboards and alarms
3. Implement CI/CD pipeline for application deployment
4. Enable VPC Flow Logs for network monitoring
5. Configure backup and disaster recovery procedures
6. Set up AWS Systems Manager Session Manager for connectivity without Bastion

## Support

For issues or questions, refer to:
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS RDS Documentation](https://docs.aws.amazon.com/rds/)

## License

This project is provided as-is for educational and production purposes.
