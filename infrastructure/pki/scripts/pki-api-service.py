# pki_api_service.py
# REST API for PKI certificate services

from flask import Flask, request, jsonify
from flask_restful import Api, Resource
from flask_jwt_extended import JWTManager, jwt_required, create_access_token
import requests
import base64
import subprocess
import logging
from datetime import datetime, timedelta
import pyodbc

app = Flask(__name__)
api = Api(app)

# Configuration
app.config["JWT_SECRET_KEY"] = "your-secret-key"
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=1)
jwt = JWTManager(app)

# Database connection
conn_str = "DRIVER={SQL Server};SERVER=SQL-PKI-DB;DATABASE=PKI_Management;Trusted_Connection=yes;"


class CertificateRequest(Resource):
    @jwt_required()
    def post(self):
        """Submit new certificate request"""
        data = request.get_json()

        # Validate request
        required_fields = ["template", "subject", "san"]
        if not all(field in data for field in required_fields):
            return {"error": "Missing required fields"}, 400

        try:
            # Generate CSR
            csr = self.generate_csr(data["subject"], data["san"])

            # Submit to CA
            cert_serial = self.submit_to_ca(csr, data["template"])

            # Log request
            self.log_request(data, cert_serial)

            return {
                "status": "success",
                "serial": cert_serial,
                "message": "Certificate request submitted successfully",
            }, 201

        except Exception as e:
            logging.error(f"Certificate request failed: {str(e)}")
            return {"error": str(e)}, 500

    def generate_csr(self, subject, san):
        """Generate certificate signing request"""
        config = f"""
        [req]
        distinguished_name = req_distinguished_name
        req_extensions = v3_req

        [req_distinguished_name]

        [v3_req]
        subjectAltName = @alt_names

        [alt_names]
        DNS.1 = {san}
        """

        # Write config to temp file
        with open("/tmp/csr.conf", "w") as f:
            f.write(config)

        # Generate private key and CSR
        subprocess.run(
            [
                "openssl",
                "req",
                "-new",
                "-newkey",
                "rsa:2048",
                "-nodes",
                "-keyout",
                "/tmp/private.key",
                "-out",
                "/tmp/request.csr",
                "-subj",
                subject,
                "-config",
                "/tmp/csr.conf",
            ]
        )

        with open("/tmp/request.csr", "r") as f:
            csr = f.read()

        return csr

    def submit_to_ca(self, csr, template):
        """Submit CSR to Certificate Authority"""
        ca_url = "https://pki-ica-01.company.local/certsrv/certfnsh.asp"

        payload = {
            "Mode": "newreq",
            "CertRequest": csr,
            "CertAttrib": f"CertificateTemplate:{template}",
            "TargetStoreFlags": "0",
            "SaveCert": "yes",
        }

        response = requests.post(
            ca_url, data=payload, auth=("domain\\username", "password")
        )

        # Parse response for serial number
        # This is simplified - actual implementation would parse HTML response
        serial = response.text.split("Serial Number:")[1].split("<")[0].strip()

        return serial

    def log_request(self, data, serial):
        """Log certificate request to database"""
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()

        cursor.execute(
            """
            INSERT INTO CertificateRequests
            (RequestDate, Template, Subject, SAN, Serial, Requester, Status)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
            datetime.now(),
            data["template"],
            data["subject"],
            data.get("san"),
            serial,
            request.headers.get("X-User"),
            "Issued",
        )

        conn.commit()
        conn.close()


class CertificateRetrieval(Resource):
    @jwt_required()
    def get(self, serial):
        """Retrieve certificate by serial number"""
        try:
            conn = pyodbc.connect(conn_str)
            cursor = conn.cursor()

            cursor.execute(
                """
                SELECT Certificate, IssuedDate, ExpiryDate, Status
                FROM Certificates
                WHERE Serial = ?
            """,
                serial,
            )

            row = cursor.fetchone()

            if row:
                return {
                    "serial": serial,
                    "certificate": base64.b64encode(row[0]).decode(),
                    "issued": row[1].isoformat(),
                    "expiry": row[2].isoformat(),
                    "status": row[3],
                }, 200
            else:
                return {"error": "Certificate not found"}, 404

        except Exception as e:
            logging.error(f"Certificate retrieval failed: {str(e)}")
            return {"error": str(e)}, 500


class CertificateRevocation(Resource):
    @jwt_required()
    def post(self, serial):
        """Revoke certificate"""
        data = request.get_json()
        reason = data.get("reason", "unspecified")

        try:
            # Call certutil to revoke certificate
            result = subprocess.run(
                ["certutil", "-revoke", serial, reason], capture_output=True, text=True
            )

            if result.returncode == 0:
                # Update database
                conn = pyodbc.connect(conn_str)
                cursor = conn.cursor()

                cursor.execute(
                    """
                    UPDATE Certificates
                    SET Status = 'Revoked', RevokedDate = ?, RevokedReason = ?
                    WHERE Serial = ?
                """,
                    datetime.now(),
                    reason,
                    serial,
                )

                conn.commit()
                conn.close()

                return {
                    "status": "success",
                    "message": f"Certificate {serial} revoked",
                }, 200
            else:
                return {"error": result.stderr}, 500

        except Exception as e:
            logging.error(f"Certificate revocation failed: {str(e)}")
            return {"error": str(e)}, 500


class CertificateValidation(Resource):
    def post(self):
        """Validate certificate chain"""
        data = request.get_json()
        cert_pem = data.get("certificate")

        if not cert_pem:
            return {"error": "Certificate required"}, 400

        try:
            # Write certificate to temp file
            with open("/tmp/cert.pem", "w") as f:
                f.write(cert_pem)

            # Validate against CA chain
            result = subprocess.run(
                [
                    "openssl",
                    "verify",
                    "-CAfile",
                    "/etc/pki/ca-chain.pem",
                    "/tmp/cert.pem",
                ],
                capture_output=True,
                text=True,
            )

            if result.returncode == 0:
                # Parse certificate details
                cert_info = subprocess.run(
                    [
                        "openssl",
                        "x509",
                        "-in",
                        "/tmp/cert.pem",
                        "-noout",
                        "-subject",
                        "-issuer",
                        "-serial",
                        "-dates",
                    ],
                    capture_output=True,
                    text=True,
                )

                return {"valid": True, "details": cert_info.stdout}, 200
            else:
                return {"valid": False, "error": result.stderr}, 200

        except Exception as e:
            logging.error(f"Certificate validation failed: {str(e)}")
            return {"error": str(e)}, 500


# Authentication endpoint
@app.route("/api/auth", methods=["POST"])
def authenticate():
    username = request.json.get("username")
    password = request.json.get("password")

    # Validate credentials against AD
    # This is simplified - actual implementation would use LDAP
    if validate_ad_credentials(username, password):
        access_token = create_access_token(identity=username)
        return jsonify(access_token=access_token), 200
    else:
        return jsonify(error="Invalid credentials"), 401


# API endpoints
api.add_resource(CertificateRequest, "/api/certificate/request")
api.add_resource(CertificateRetrieval, "/api/certificate/<string:serial>")
api.add_resource(CertificateRevocation, "/api/certificate/<string:serial>/revoke")
api.add_resource(CertificateValidation, "/api/certificate/validate")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, ssl_context="adhoc")
