# F5 BIG-IP TMSH Configuration Script

# 1. Import certificates and keys
tmsh install sys crypto cert CompanyRootCA from-local-file /var/tmp/CompanyRootCA.crt
tmsh install sys crypto cert IssuingCA01 from-local-file /var/tmp/IssuingCA01.crt
tmsh install sys crypto cert wildcard.company.com from-local-file /var/tmp/wildcard.crt
tmsh install sys crypto key wildcard.company.com from-local-file /var/tmp/wildcard.key

# 2. Create certificate chain
tmsh create sys crypto cert-chain company-chain \
    certs add { wildcard.company.com IssuingCA01 CompanyRootCA }

# 3. Create client SSL profile with OCSP
tmsh create ltm profile client-ssl Company-ClientSSL \
    cert wildcard.company.com \
    key wildcard.company.com \
    chain company-chain \
    ciphers "ECDHE+RSA+AES256:ECDHE+RSA+AES128:!MD5:!EXPORT:!DES:!DHE:!EDH:!RC4:!ADH:!SSLv3:!TLSv1" \
    options { dont-insert-empty-fragments no-tlsv1 no-tlsv1.1 } \
    ocsp-stapling enabled

# 4. Create server SSL profile for backend
tmsh create ltm profile server-ssl Company-ServerSSL \
    cert wildcard.company.com \
    key wildcard.company.com \
    ciphers "DEFAULT" \
    secure-renegotiation require

# 5. Configure OCSP responder
tmsh create ltm auth ocsp-responder CompanyOCSP \
    url http://ocsp.company.com/ocsp \
    signer wildcard.company.com

# 6. Create certificate validation profile
tmsh create ltm auth cert-ldap Company-Cert-Validation \
    servers add { 10.50.1.40 } \
    search-base "dc=company,dc=com" \
    search-filter "(objectClass=pkiUser)"

# 7. Configure client certificate authentication
tmsh create ltm auth ssl-cc-ldap Company-Client-Cert \
    cert-validation Company-Cert-Validation \
    cert-map { cert-subject-cn }

# 8. Create iRule for certificate inspection
tmsh create ltm rule Certificate-Logging {
    when CLIENTSSL_CLIENTCERT {
        if {[SSL::cert count] > 0} {
            set subject [X509::subject [SSL::cert 0]]
            set issuer [X509::issuer [SSL::cert 0]]
            set serial [X509::serial_number [SSL::cert 0]]
            log local0. "Client Certificate: Subject=$subject Issuer=$issuer Serial=$serial"

            # Check certificate validity
            set notafter [X509::not_after [SSL::cert 0]]
            set now [clock seconds]
            set expire_days [expr {($notafter - $now) / 86400}]

            if {$expire_days < 30} {
                log local0.warning "Certificate expiring soon: $subject expires in $expire_days days"
            }
        }
    }
}

# 9. Apply to virtual server
tmsh create ltm virtual VS-Portal-443 \
    destination 10.20.1.103:443 \
    ip-protocol tcp \
    profiles add { Company-ClientSSL { context clientside } Company-ServerSSL { context serverside } } \
    rules { Certificate-Logging } \
    source-address-translation { type automap } \
    pool Portal-Pool

# 10. Configure automatic certificate renewal via iControl REST
tmsh create sys application service PKI-Auto-Renewal \
    template f5.http \
    variables add { \
        renewal_script { value {
            # Script to check and renew certificates
            # Integrates with Azure Key Vault API
        }}
    }

# Save configuration
tmsh save sys config