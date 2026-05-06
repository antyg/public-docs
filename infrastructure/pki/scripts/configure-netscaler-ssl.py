#!/usr/bin/env python3
# configure_netscaler_ssl.py
# Configures SSL certificates on NetScaler ADC

import requests
import json
import base64
from datetime import datetime


class NetScalerSSLConfig:
    def __init__(self, nsip, username, password):
        self.nsip = nsip
        self.base_url = f"https://{nsip}/nitro/v1/config"
        self.session = requests.Session()
        self.session.headers.update(
            {
                "Content-Type": "application/json",
                "X-NITRO-USER": username,
                "X-NITRO-PASS": password,
            }
        )
        self.session.verify = False

    def upload_certificate(self, cert_name, cert_content, key_content):
        """Upload certificate and key to NetScaler"""

        # Upload certificate file
        cert_data = {
            "systemfile": {
                "filename": f"{cert_name}.crt",
                "filecontent": base64.b64encode(cert_content.encode()).decode(),
                "filelocation": "/nsconfig/ssl/",
                "fileencoding": "BASE64",
            }
        }

        response = self.session.post(f"{self.base_url}/systemfile", json=cert_data)

        if response.status_code != 201:
            raise Exception(f"Failed to upload certificate: {response.text}")

        # Upload key file
        key_data = {
            "systemfile": {
                "filename": f"{cert_name}.key",
                "filecontent": base64.b64encode(key_content.encode()).decode(),
                "filelocation": "/nsconfig/ssl/",
                "fileencoding": "BASE64",
            }
        }

        response = self.session.post(f"{self.base_url}/systemfile", json=key_data)

        if response.status_code != 201:
            raise Exception(f"Failed to upload key: {response.text}")

        print(f"Certificate {cert_name} uploaded successfully")

    def create_certkey_pair(self, certkey_name, cert_file, key_file):
        """Create certificate-key pair"""

        certkey_data = {
            "sslcertkey": {
                "certkey": certkey_name,
                "cert": f"/nsconfig/ssl/{cert_file}",
                "key": f"/nsconfig/ssl/{key_file}",
                "inform": "PEM",
                "passplain": "",
            }
        }

        response = self.session.post(f"{self.base_url}/sslcertkey", json=certkey_data)

        if response.status_code not in [201, 409]:  # 409 = already exists
            raise Exception(f"Failed to create certkey: {response.text}")

        print(f"Certificate-key pair {certkey_name} created")

    def bind_cert_to_vserver(self, vserver_name, certkey_name):
        """Bind certificate to virtual server"""

        binding_data = {
            "sslvserver_sslcertkey_binding": {
                "vservername": vserver_name,
                "certkeyname": certkey_name,
                "snicert": True,
            }
        }

        response = self.session.post(
            f"{self.base_url}/sslvserver_sslcertkey_binding", json=binding_data
        )

        if response.status_code not in [201, 409]:
            raise Exception(f"Failed to bind certificate: {response.text}")

        print(f"Certificate bound to vserver {vserver_name}")

    def configure_ssl_parameters(self, vserver_name):
        """Configure SSL parameters for security"""

        ssl_params = {
            "sslvserver": {
                "vservername": vserver_name,
                "ssl3": "DISABLED",
                "tls1": "DISABLED",
                "tls11": "DISABLED",
                "tls12": "ENABLED",
                "tls13": "ENABLED",
                "snienable": "ENABLED",
                "sendclosenotify": "YES",
                "cleartextport": 0,
                "dh": "ENABLED",
                "dhfile": "/nsconfig/ssl/dhparam2048.pem",
                "ersa": "ENABLED",
                "sessreuse": "ENABLED",
                "sesstimeout": 120,
                "cipherredirect": "DISABLED",
                "sslredirect": "ENABLED",
            }
        }

        response = self.session.put(
            f"{self.base_url}/sslvserver/{vserver_name}", json=ssl_params
        )

        if response.status_code != 200:
            raise Exception(f"Failed to configure SSL parameters: {response.text}")

        print(f"SSL parameters configured for {vserver_name}")

    def configure_cipher_suites(self, vserver_name):
        """Configure secure cipher suites"""

        # Create custom cipher group
        cipher_group = {
            "sslcipher": {
                "ciphergroupname": "SECURE_CIPHER_GROUP_2025",
                "ciphernamesuite": [
                    "TLS1.3-AES256-GCM-SHA384",
                    "TLS1.3-AES128-GCM-SHA256",
                    "TLS1.2-ECDHE-RSA-AES256-GCM-SHA384",
                    "TLS1.2-ECDHE-RSA-AES128-GCM-SHA256",
                    "TLS1.2-ECDHE-ECDSA-AES256-GCM-SHA384",
                    "TLS1.2-ECDHE-ECDSA-AES128-GCM-SHA256",
                ],
            }
        }

        # Bind cipher group to vserver
        binding_data = {
            "sslvserver_sslcipher_binding": {
                "vservername": vserver_name,
                "ciphername": "SECURE_CIPHER_GROUP_2025",
            }
        }

        response = self.session.post(
            f"{self.base_url}/sslvserver_sslcipher_binding", json=binding_data
        )

        print(f"Cipher suites configured for {vserver_name}")


# Main configuration
if __name__ == "__main__":
    # NetScaler details
    NS_IP = "10.20.1.10"
    NS_USER = "nsadmin"
    NS_PASS = "nspassword"

    # Initialize NetScaler configuration
    ns = NetScalerSSLConfig(NS_IP, NS_USER, NS_PASS)

    # Virtual servers to configure
    vservers = [
        {
            "name": "VS_Company_Portal_443",
            "cert_name": "portal_company_com_au",
            "hostname": "portal.company.com.au",
        },
        {
            "name": "VS_API_Gateway_443",
            "cert_name": "api_company_com_au",
            "hostname": "api.company.com.au",
        },
        {
            "name": "VS_Web_Services_443",
            "cert_name": "www_company_com_au",
            "hostname": "www.company.com.au",
        },
    ]

    for vserver in vservers:
        print(f"\nConfiguring {vserver['name']}...")

        # Get certificate from PKI
        # This would retrieve cert from CA or Key Vault
        cert_content = get_certificate_from_pki(vserver["hostname"])
        key_content = get_private_key_from_pki(vserver["hostname"])

        # Upload certificate
        ns.upload_certificate(vserver["cert_name"], cert_content, key_content)

        # Create cert-key pair
        ns.create_certkey_pair(
            vserver["cert_name"],
            f"{vserver['cert_name']}.crt",
            f"{vserver['cert_name']}.key",
        )

        # Bind to vserver
        ns.bind_cert_to_vserver(vserver["name"], vserver["cert_name"])

        # Configure SSL parameters
        ns.configure_ssl_parameters(vserver["name"])

        # Configure cipher suites
        ns.configure_cipher_suites(vserver["name"])

    print("\nNetScaler SSL configuration complete!")
