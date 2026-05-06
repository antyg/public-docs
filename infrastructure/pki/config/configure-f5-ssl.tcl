# configure_f5_ssl.tcl
# F5 BIG-IP SSL certificate configuration

# Create SSL profiles
tmsh create ltm profile client-ssl /PKI/clientssl_company_2025 {
    cert /PKI/company_wildcard_2025.crt
    key /PKI/company_wildcard_2025.key
    chain /PKI/company_chain_2025.crt
    ciphers "TLSv1_3:TLSv1_2+ECDHE:TLSv1_2+DHE:!SSLv3:!RC4:!DES"
    options { no-sslv3 no-tlsv1 no-tlsv1_1 }
    secure-renegotiation require
    server-name company.com.au
    sni-default true
    strict-resume enabled
}

tmsh create ltm profile server-ssl /PKI/serverssl_backend {
    cert /PKI/backend_client_2025.crt
    key /PKI/backend_client_2025.key
    ciphers "DEFAULT"
    secure-renegotiation require-strict
    server-name backend.company.local
}

# Create certificate monitoring
tmsh create sys icall event /PKI/cert_expiry_check {
    event-name "cert_expiry_check"
}

tmsh create sys icall handler /PKI/cert_expiry_handler {
    event-name cert_expiry_check
    script {
        set cert_list [tmsh list sys crypto cert]
        foreach cert $cert_list {
            set expiry [tmsh show sys crypto cert $cert expiration-date]
            set days_left [expr {($expiry - [clock seconds]) / 86400}]

            if { $days_left < 30 } {
                tmsh create sys log-config publisher /PKI/cert_alert {
                    description "Certificate $cert expires in $days_left days"
                }
            }
        }
    }
}

# Create iRule for certificate validation
tmsh create ltm rule /PKI/cert_validation_rule {
    when CLIENTSSL_CLIENTCERT {
        # Check if client certificate was provided
        if {[SSL::cert count] > 0} {
            # Extract certificate information
            set cert_subject [X509::subject [SSL::cert 0]]
            set cert_issuer [X509::issuer [SSL::cert 0]]
            set cert_serial [X509::serial_number [SSL::cert 0]]

            # Validate issuer
            if { $cert_issuer contains "Company Issuing CA" } {
                # Certificate is from our CA
                HTTP::header insert X-Client-Certificate-Subject $cert_subject
                HTTP::header insert X-Client-Certificate-Serial $cert_serial
                log local0. "Valid client certificate: $cert_subject"
            } else {
                # Invalid issuer
                reject
                log local0. "Invalid certificate issuer: $cert_issuer"
            }
        } else {
            # No client certificate provided
            HTTP::respond 403 content "Client certificate required"
        }
    }
}

# Apply to virtual servers
tmsh modify ltm virtual /PKI/vs_company_portal_443 {
    profiles add { /PKI/clientssl_company_2025 { context clientside } }
    profiles add { /PKI/serverssl_backend { context serverside } }
    rules { /PKI/cert_validation_rule }
}

# Save configuration
tmsh save sys config