#!/usr/bin/env python3
# cisco_scep_enrollment.py

import requests
import hashlib
import base64
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa


class SCEPClient:
    def __init__(self, scep_url, challenge_password):
        self.scep_url = scep_url
        self.challenge = challenge_password

    def get_ca_cert(self):
        """Retrieve CA certificate"""
        response = requests.get(
            f"{self.scep_url}?operation=GetCACert",
            headers={"Content-Type": "application/x-pki-message"},
        )
        return x509.load_der_x509_certificate(response.content)

    def generate_csr(self, common_name, key_size=2048):
        """Generate key pair and CSR"""
        # Generate private key
        private_key = rsa.generate_private_key(public_exponent=65537, key_size=key_size)

        # Build CSR
        subject = x509.Name(
            [
                x509.NameAttribute(x509.oid.NameOID.COMMON_NAME, common_name),
                x509.NameAttribute(x509.oid.NameOID.ORGANIZATION_NAME, "Company"),
                x509.NameAttribute(x509.oid.NameOID.COUNTRY_NAME, "AU"),
            ]
        )

        csr = (
            x509.CertificateSigningRequestBuilder()
            .subject_name(subject)
            .add_extension(
                x509.SubjectAlternativeName(
                    [
                        x509.DNSName(common_name),
                        x509.DNSName(f"{common_name}.company.com.au"),
                    ]
                ),
                critical=False,
            )
            .sign(private_key, hashes.SHA256())
        )

        return private_key, csr

    def enroll_certificate(self, csr):
        """Submit SCEP enrollment request"""
        # Create PKCS#7 message
        pkcs7_data = self.create_pkcs7_request(csr)

        response = requests.post(
            f"{self.scep_url}?operation=PKIOperation",
            data=pkcs7_data,
            headers={
                "Content-Type": "application/x-pki-message",
                "Content-Transfer-Encoding": "base64",
            },
        )

        if response.status_code == 200:
            return self.parse_certificate_response(response.content)
        else:
            raise Exception(f"Enrollment failed: {response.status_code}")


# Cisco IOS Configuration
cisco_config = """
crypto pki trustpoint COMPANY-SCEP
 enrollment mode ra
 enrollment url http://ndes.company.com.au/certsrv/mscep/mscep.dll
 enrollment retry count 3
 enrollment retry period 1
 fqdn switch01.company.com.au
 subject-name CN=switch01.company.com.au,OU=Network,O=Company,C=AU
 revocation-check crl
 rsakeypair COMPANY-KEY 2048
 auto-enroll 80

crypto pki authenticate COMPANY-SCEP
crypto pki enroll COMPANY-SCEP
"""
