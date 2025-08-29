#!/bin/bash
# Linux ACME Certificate Enrollment Script

# Configuration
ACME_SERVER="https://acme.company.com.au/directory"
CERT_PATH="/etc/pki/tls/certs"
KEY_PATH="/etc/pki/tls/private"
ACCOUNT_KEY="/etc/acme/account.key"

# Install certbot if not present
if ! command -v certbot &> /dev/null; then
    if command -v yum &> /dev/null; then
        yum install -y certbot
    elif command -v apt-get &> /dev/null; then
        apt-get install -y certbot
    else
        echo "Package manager not supported"
        exit 1
    fi
fi

# Register ACME account
certbot register \
    --server $ACME_SERVER \
    --agree-tos \
    --email admin@company.com.au \
    --no-eff-email

# Request certificate with DNS challenge
request_certificate() {
    local domain=$1
    local type=${2:-"webserver"}
    
    certbot certonly \
        --server $ACME_SERVER \
        --dns-route53 \
        --dns-route53-propagation-seconds 30 \
        -d $domain \
        -d www.$domain \
        --cert-name $domain \
        --key-type rsa \
        --rsa-key-size 2048 \
        --cert-path $CERT_PATH \
        --key-path $KEY_PATH \
        --preferred-challenges dns-01 \
        --non-interactive
}

# Automated renewal
setup_renewal() {
    cat > /etc/cron.d/certbot-renewal << EOF
# Certbot renewal job
0 2 * * * root certbot renew --quiet --no-self-upgrade --post-hook "systemctl reload nginx"
EOF
    
    # Systemd timer alternative
    cat > /etc/systemd/system/certbot-renewal.service << EOF
[Unit]
Description=Certbot Renewal
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/certbot renew --quiet --no-self-upgrade
ExecStartPost=/bin/systemctl reload nginx

[Install]
WantedBy=multi-user.target
EOF
    
    cat > /etc/systemd/system/certbot-renewal.timer << EOF
[Unit]
Description=Run certbot renewal twice daily

[Timer]
OnCalendar=*-*-* 00,12:00:00
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
EOF
    
    systemctl daemon-reload
    systemctl enable --now certbot-renewal.timer
}

# OpenSSL manual enrollment
manual_enrollment() {
    local cn=$1
    local sans=$2
    
    # Generate private key
    openssl genrsa -out ${KEY_PATH}/${cn}.key 2048
    
    # Create config file
    cat > /tmp/${cn}.cnf << EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = AU
ST = New South Wales
L = Sydney
O = Company
OU = IT Department
CN = ${cn}

[v3_req]
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${cn}
${sans}
EOF
    
    # Generate CSR
    openssl req -new \
        -key ${KEY_PATH}/${cn}.key \
        -out /tmp/${cn}.csr \
        -config /tmp/${cn}.cnf
    
    # Submit to CA (via curl)
    curl -X POST https://ca.company.com.au/api/request \
        -H "Content-Type: application/pkcs10" \
        -H "Authorization: Bearer ${API_TOKEN}" \
        --data-binary @/tmp/${cn}.csr \
        -o ${CERT_PATH}/${cn}.crt
}

# Main execution
case "$1" in
    request)
        request_certificate $2 $3
        ;;
    renew)
        certbot renew
        ;;
    setup)
        setup_renewal
        ;;
    manual)
        manual_enrollment $2 "$3"
        ;;
    *)
        echo "Usage: $0 {request|renew|setup|manual} [domain] [SANs]"
        exit 1
        ;;
esac