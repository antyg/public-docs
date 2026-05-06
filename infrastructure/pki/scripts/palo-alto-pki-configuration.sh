#!/bin/bash
# Palo Alto PAN-OS PKI Configuration Script
# Execute via CLI or Panorama

# 1. Import CA certificates
request certificate fetch ca-certificate url "http://pki.company.com/CompanyRootCA.crt"
request certificate fetch ca-certificate url "http://pki.company.com/IssuingCA01.crt"

# 2. Configure certificate profile for validation
set shared certificate-profile Company-Cert-Profile \
    CA CompanyRootCA \
    ocsp-url "http://ocsp.company.com/ocsp" \
    crl-receive-url "http://crl.company.com/crl/IssuingCA01.crl" \
    block-unknown-cert yes \
    block-timeout-cert yes \
    block-expired-cert yes

# 3. Create SSL decryption profile
set shared ssl-decryption ssl-forward-proxy Company-Forward-Proxy \
    strip-alpn yes \
    block-client-cert no \
    block-expired-certificate yes \
    block-untrusted-issuer yes \
    block-unknown-cert yes

# 4. Configure SSL decryption policy
set rulebase decryption rules SSL-Decrypt-Policy \
    from any to any \
    source any destination any \
    service any application any \
    decrypt-type ssl-forward-proxy \
    profile Company-Forward-Proxy \
    log-start yes log-end yes

# 5. Add SSL decryption exemptions
set rulebase decryption rules No-Decrypt-PKI \
    from any to any \
    source any destination [ ocsp.company.com crl.company.com pki.company.com ] \
    service any application any \
    action no-decrypt \
    log-start yes

# 6. Configure certificate for management interface
request certificate generate name Mgmt-Interface-Cert \
    certificate-name "CN=fw-mgmt.company.com" \
    algorithm RSA rsa-nbits 2048 \
    digest sha256 \
    signed-by external

# 7. Configure OCSP responder settings
set deviceconfig system ocsp-responder CompanyOCSP \
    url "http://ocsp.company.com/ocsp" \
    certificate-profile Company-Cert-Profile

# 8. Enable certificate status monitoring
set deviceconfig system certificate-monitoring enabled yes \
    notification-email security@company.com \
    expiry-threshold 30

# 9. Configure syslog for certificate events
set shared log-settings syslog PKI-Events \
    server PKI-Syslog server 10.50.1.50 \
    facility LOG_LOCAL3 \
    port 514 \
    format BSD

# 10. Commit configuration
commit description "PKI Integration - Certificate Management"