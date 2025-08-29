# NetScaler SSL Configuration Script
# Configure-NetScaler-SSL.sh

#!/bin/bash

# NetScaler connection details
NS_IP="10.20.1.10"
NS_USER="nsadmin"
NS_PASS="YourSecurePassword"

# SSH command function
ns_command() {
    ssh ${NS_USER}@${NS_IP} "$1"
}

echo "==========================================="
echo "NetScaler SSL Certificate Configuration"
echo "==========================================="

# 1. Upload Root and Intermediate certificates
echo "Uploading Root CA certificate..."
scp /path/to/CompanyRootCA.crt ${NS_USER}@${NS_IP}:/nsconfig/ssl/

echo "Uploading Intermediate CA certificates..."
scp /path/to/IssuingCA01.crt ${NS_USER}@${NS_IP}:/nsconfig/ssl/
scp /path/to/IssuingCA02.crt ${NS_USER}@${NS_IP}:/nsconfig/ssl/

# 2. Configure certificates via CLI
echo "Configuring certificates..."

ns_command "add ssl certKey CompanyRootCA -cert /nsconfig/ssl/CompanyRootCA.crt -inform PEM"
ns_command "add ssl certKey CompanyIntCA01 -cert /nsconfig/ssl/IssuingCA01.crt -inform PEM"
ns_command "add ssl certKey CompanyIntCA02 -cert /nsconfig/ssl/IssuingCA02.crt -inform PEM"

# 3. Link certificate chain
echo "Linking certificate chain..."
ns_command "link ssl certKey CompanyIntCA01 CompanyRootCA"
ns_command "link ssl certKey CompanyIntCA02 CompanyRootCA"

# 4. Create SSL certificate for services
echo "Creating SSL certificate for services..."
ns_command "add ssl certKey Wildcard-Company-2024 -cert /nsconfig/ssl/wildcard.company.com.crt -key /nsconfig/ssl/wildcard.company.com.key -inform PEM -expiryMonitor ENABLED -notificationPeriod 30"

# 5. Link server certificate to intermediate
ns_command "link ssl certKey Wildcard-Company-2024 CompanyIntCA01"

# 6. Create SSL profiles with strong ciphers
echo "Creating SSL profiles..."
ns_command "add ssl profile SSL-Profile-Frontend -eRSA ENABLED -eRSACount 1000 -sessReuse ENABLED -sessTimeout 120 -tls1 DISABLED -tls11 DISABLED -tls12 ENABLED -tls13 ENABLED -HSTS ENABLED -maxage 31536000 -includeSubdomains YES"

ns_command "add ssl profile SSL-Profile-Backend -eRSA ENABLED -sessReuse ENABLED -sessTimeout 120"

# 7. Configure OCSP responder
echo "Configuring OCSP responder..."
ns_command "add ssl ocspResponder OCSP-Responder -url http://ocsp.company.com/ocsp -cache ENABLED -cacheTimeout 30 -batchingDepth 5 -batchingDelay 10"

# 8. Bind OCSP to certificate
ns_command "set ssl certKey Wildcard-Company-2024 -ocspResponder OCSP-Responder"

# 9. Configure client certificate authentication
echo "Configuring client certificate authentication..."
ns_command "add ssl certKey ClientCA-Company -cert /nsconfig/ssl/ClientCA.crt -inform PEM"
ns_command "add ssl policy ClientCert-Policy -rule 'CLIENT.SSL.CLIENT_CERT.EXISTS' -action ALLOW"

# 10. Create virtual servers with SSL
echo "Creating virtual servers..."

# Portal VIP
ns_command "add lb vserver VS-Portal-SSL SSL 10.20.1.100 443 -persistenceType SOURCEIP -timeout 120"
ns_command "bind lb vserver VS-Portal-SSL Wildcard-Company-2024"
ns_command "bind lb vserver VS-Portal-SSL -policyName ClientCert-Policy -priority 100"
ns_command "set ssl vserver VS-Portal-SSL -sslProfile SSL-Profile-Frontend"

# API Gateway VIP
ns_command "add lb vserver VS-API-SSL SSL 10.20.1.101 443 -persistenceType SOURCEIP -timeout 120"
ns_command "bind lb vserver VS-API-SSL Wildcard-Company-2024"
ns_command "set ssl vserver VS-API-SSL -sslProfile SSL-Profile-Frontend"

# Admin VIP with client cert requirement
ns_command "add lb vserver VS-Admin-SSL SSL 10.20.1.102 443 -persistenceType SOURCEIP -timeout 120"
ns_command "bind lb vserver VS-Admin-SSL Wildcard-Company-2024"
ns_command "bind lb vserver VS-Admin-SSL -policyName ClientCert-Policy -priority 100 -gotoPriorityExpression END"
ns_command "set ssl vserver VS-Admin-SSL -sslProfile SSL-Profile-Frontend -clientAuth ENABLED -clientCert Mandatory"

# 11. Enable SSL session reuse globally
echo "Enabling SSL session reuse..."
ns_command "set ssl parameter -defaultProfile ENABLED -denySSLReneg NONSECURE -insertionEncoding UTF-8 -quantumSize 8192"

# 12. Configure SSL cipher groups
echo "Configuring SSL cipher groups..."
ns_command "bind ssl profile SSL-Profile-Frontend -cipherName TLS1.3-AES256-GCM-SHA384 -cipherPriority 1"
ns_command "bind ssl profile SSL-Profile-Frontend -cipherName TLS1.3-AES128-GCM-SHA256 -cipherPriority 2"
ns_command "bind ssl profile SSL-Profile-Frontend -cipherName TLS1.2-ECDHE-RSA-AES256-GCM-SHA384 -cipherPriority 3"
ns_command "bind ssl profile SSL-Profile-Frontend -cipherName TLS1.2-ECDHE-RSA-AES128-GCM-SHA256 -cipherPriority 4"

# 13. Save configuration
echo "Saving configuration..."
ns_command "save ns config"

echo "==========================================="
echo "NetScaler SSL configuration completed!"
echo "==========================================="

# Verify configuration
echo "Verifying configuration..."
ns_command "show ssl certKey"
ns_command "show ssl vserver"
ns_command "show ssl profile"

echo "Configuration verification completed."