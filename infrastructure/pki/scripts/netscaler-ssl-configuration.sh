#!/bin/bash
# NetScaler CLI Configuration Script
# SSH to NetScaler primary node and execute these commands

# 1. Upload Root and Intermediate certificates
add ssl certKey CompanyRootCA -cert "/nsconfig/ssl/CompanyRootCA.crt" -inform PEM
add ssl certKey CompanyIntCA01 -cert "/nsconfig/ssl/IssuingCA01.crt" -inform PEM
add ssl certKey CompanyIntCA02 -cert "/nsconfig/ssl/IssuingCA02.crt" -inform PEM

# 2. Link certificate chain
link ssl certKey CompanyIntCA01 CompanyRootCA
link ssl certKey CompanyIntCA02 CompanyRootCA

# 3. Create SSL certificate for services
add ssl certKey Wildcard-Company-2024 \
    -cert "/nsconfig/ssl/wildcard.company.com.crt" \
    -key "/nsconfig/ssl/wildcard.company.com.key" \
    -inform PEM \
    -expiryMonitor ENABLED \
    -notificationPeriod 30

# 4. Link server certificate to intermediate
link ssl certKey Wildcard-Company-2024 CompanyIntCA01

# 5. Create SSL profiles with strong ciphers
add ssl profile SSL-Profile-Frontend -eRSA ENABLED -eRSACount 1000 \
    -sessReuse ENABLED -sessTimeout 120 \
    -tls1 DISABLED -tls11 DISABLED -tls12 ENABLED -tls13 ENABLED \
    -HSTS ENABLED -maxage 31536000 -includeSubdomains YES

# 6. Configure OCSP responder
add ssl ocspResponder OCSP-Responder \
    -url "http://ocsp.company.com/ocsp" \
    -cache ENABLED \
    -cacheTimeout 30 \
    -batchingDepth 5 \
    -batchingDelay 10

# 7. Bind OCSP to certificate
set ssl certKey Wildcard-Company-2024 -ocspResponder OCSP-Responder

# 8. Configure client certificate authentication
add ssl certKey ClientCA-Company -cert "/nsconfig/ssl/ClientCA.crt" -inform PEM
add ssl policy ClientCert-Policy -rule "CLIENT.SSL.CLIENT_CERT.EXISTS" \
    -action ALLOW

# 9. Create virtual server with SSL
add lb vserver VS-Portal-SSL SSL 10.20.1.100 443 \
    -persistenceType SOURCEIP -timeout 120
bind lb vserver VS-Portal-SSL Wildcard-Company-2024
bind lb vserver VS-Portal-SSL -policyName ClientCert-Policy -priority 100
set ssl vserver VS-Portal-SSL -sslProfile SSL-Profile-Frontend

# 10. Enable SSL session reuse
set ssl parameter -defaultProfile ENABLED -denySSLReneg NONSECURE \
    -insertionEncoding UTF-8 -quantumSize 8192