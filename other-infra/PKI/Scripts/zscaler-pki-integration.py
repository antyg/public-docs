# Python script for Zscaler API integration
import requests
import json
from cryptography import x509
from cryptography.hazmat.backends import default_backend
import base64
import time


class ZscalerPKIIntegration:
    def __init__(self, cloud, api_key, username, password):
        self.base_url = f"https://zsapi.{cloud}.net/api/v1"
        self.api_key = api_key
        self.username = username
        self.password = password
        self.session = None

    def authenticate(self):
        """Authenticate to Zscaler API"""
        auth_url = f"{self.base_url}/authenticatedSession"

        # Obfuscate credentials
        timestamp = str(int(time.time() * 1000))
        obfuscated_password = self.obfuscate_password(timestamp)

        payload = {
            "apiKey": self.api_key,
            "username": self.username,
            "password": obfuscated_password,
            "timestamp": timestamp,
        }

        response = requests.post(auth_url, json=payload)
        if response.status_code == 200:
            self.session = response.cookies.get("JSESSIONID")
            return True
        return False

    def upload_intermediate_ca(self, cert_path):
        """Upload intermediate CA certificate to Zscaler"""
        url = f"{self.base_url}/sslSettings/intermediateCaCert"

        with open(cert_path, "rb") as f:
            cert_data = f.read()

        cert = x509.load_pem_x509_certificate(cert_data, default_backend())

        payload = {
            "certificate": base64.b64encode(cert_data).decode("utf-8"),
            "description": f"Company Issuing CA - {cert.subject.rfc4514_string()}",
            "certificateUsage": "INTERMEDIATE_CA",
        }

        headers = {"Cookie": f"JSESSIONID={self.session}"}
        response = requests.post(url, json=payload, headers=headers)

        return response.json()

    def configure_ssl_inspection_policy(self):
        """Configure SSL inspection exemptions for certificate services"""
        url = f"{self.base_url}/sslSettings/exemptedUrls"

        exemptions = [
            {"url": "ocsp.company.com", "description": "Company OCSP Responder"},
            {"url": "crl.company.com", "description": "Company CRL Distribution"},
            {"url": "pki.company.com", "description": "PKI Web Enrollment"},
            {"url": "*.digicert.com", "description": "DigiCert Services"},
            {"url": "*.microsoft.com/pki/*", "description": "Microsoft PKI Services"},
        ]

        headers = {"Cookie": f"JSESSIONID={self.session}"}

        for exemption in exemptions:
            response = requests.post(url, json=exemption, headers=headers)
            print(f"Added exemption for {exemption['url']}: {response.status_code}")

    def configure_client_certificate_policy(self):
        """Configure ZPA client certificate requirements"""
        url = f"{self.base_url}/clientCertificate/profiles"

        profile = {
            "name": "Company-Device-Certificate",
            "description": "Company managed device certificates",
            "certificateAttributes": {
                "cn": "*.company.com",
                "ou": "IT Department",
                "o": "Company Inc",
            },
            "validationRules": [
                {"type": "OCSP", "url": "http://ocsp.company.com/ocsp"},
                {"type": "CRL", "url": "http://crl.company.com/crl/IssuingCA01.crl"},
            ],
            "requireStrictValidation": True,
        }

        headers = {"Cookie": f"JSESSIONID={self.session}"}
        response = requests.post(url, json=profile, headers=headers)

        return response.json()


# Execute Zscaler configuration
zscaler = ZscalerPKIIntegration(
    cloud="zscaler.net",
    api_key="YOUR_API_KEY",
    username="admin@company.com",
    password="secure_password",
)

if zscaler.authenticate():
    zscaler.upload_intermediate_ca("/path/to/IssuingCA01.crt")
    zscaler.configure_ssl_inspection_policy()
    zscaler.configure_client_certificate_policy()
