#!/bin/bash
set -e

# Update system
yum update -y

# Install Apache HTTP Server (httpd)
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Install MySQL client
yum install -y mysql

# Create a simple HTML page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to App Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; background-color: #f0f0f0; }
        .container { background-color: white; padding: 20px; border-radius: 5px; }
        h1 { color: #333; }
        p { color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to the Application Server</h1>
        <p>This server is running Apache HTTP Server (httpd)</p>
        <p>Server is healthy and operational</p>
        <p>Hostname: <strong>$(hostname)</strong></p>
        <p>IP Address: <strong>$(hostname -I)</strong></p>
    </div>
</body>
</html>
EOF

# Install MySQL Server (optional - based on requirements)
# For production, it's recommended to use RDS instead
# yum install -y mysql-server
# systemctl start mysqld
# systemctl enable mysqld

# Test connectivity to MySQL if database endpoint is provided
if [ ! -z "${db_endpoint}" ]; then
    mysql -h ${db_endpoint} -u ${db_user} -p${db_password} -e "SELECT 1" > /dev/null 2>&1 || true
fi

# Log completion
echo "Server initialization completed successfully" > /var/log/user_data.log
