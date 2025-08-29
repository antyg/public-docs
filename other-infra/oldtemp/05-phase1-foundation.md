[← Previous](04-key-components.md) | [Index](00-index.md) | [Next →](06-phase2-core-infrastructure.md)

# Phase 1: Foundation Setup (Weeks 1-2)

## Overview

Phase 1 establishes the core Azure infrastructure and deploys the root certificate authority that will serve as the trust anchor for the entire PKI ecosystem.

## Week 1: Azure Infrastructure Preparation

### Day 1-2: Azure Subscription and Governance

#### Resource Group Creation
- **RG-PKI-Core**: Core PKI infrastructure components
- **RG-PKI-KeyVault**: Key Vault and HSM resources
- **RG-PKI-Networking**: Virtual networks and connectivity

#### RBAC Configuration
- Create PKI-Administrators security group
- Assign Owner role to PKI team for PKI resource groups
- Configure Azure Policy for compliance enforcement

#### Governance Policies
- Location restrictions (Australia East, Australia Southeast)
- Required tags: Environment, Department, CostCenter, Owner
- Backup requirements for critical resources

### Day 3-4: Network Configuration

#### Virtual Network Design
```
VNET-PKI (10.50.0.0/16)
├── Subnet-PKI-Core (10.50.1.0/24)
├── Subnet-PKI-HSM (10.50.2.0/24)
├── Subnet-PKI-Management (10.50.3.0/24)
└── GatewaySubnet (10.50.255.0/24)
```

#### Network Security Groups
| Rule Name | Protocol | Port | Source | Destination | Action |
|-----------|----------|------|--------|-------------|--------|
| Allow-HTTPS | TCP | 443 | VirtualNetwork | Subnet-PKI-Core | Allow |
| Allow-RPC | TCP | 135 | On-Premises | Subnet-PKI-Core | Allow |
| Allow-CRL | TCP | 80 | Internet | Subnet-PKI-Core | Allow |
| Allow-OCSP | TCP | 80 | Internet | Subnet-PKI-Core | Allow |
| Deny-All | Any | Any | Any | Any | Deny |

#### ExpressRoute/VPN Configuration
- Primary: ExpressRoute circuit to on-premises datacenter
- Backup: Site-to-site VPN with automatic failover
- BGP routing for dynamic path selection

### Day 5: Azure Key Vault Setup

#### Premium Key Vault Deployment
```yaml
Name: KV-PKI-RootCA
SKU: Premium (HSM-enabled)
Location: Australia East
Features:
  - Soft delete: Enabled (90 days)
  - Purge protection: Enabled
  - Network restrictions: Private endpoint only
  - Backup: Geo-redundant
```

#### HSM Key Configuration
- Root CA signing key: RSA-HSM 4096-bit
- Non-exportable, non-deletable
- Key rotation disabled for root CA
- Audit logging to Log Analytics

#### Access Policies
| Principal | Keys | Secrets | Certificates |
|-----------|------|---------|--------------|
| PKI-Administrators | All | All | All |
| Azure Private CA Service | Get, Sign | None | Get, List |
| Backup Service | Backup | Backup | Backup |
| Monitoring Service | List | None | List |

## Week 2: Azure Private CA Deployment

### Day 6-7: Deploy Azure Managed Private CA

#### Root CA Configuration
```yaml
Certificate Authority:
  Name: Company-Root-CA
  Type: Root CA
  Subject: CN=Company Root CA, O=Company Australia, C=AU
  Key:
    Type: RSA-HSM
    Size: 4096
    Storage: Azure Key Vault HSM
  Validity: 20 years
  Extensions:
    BasicConstraints: CA:TRUE, pathlen:2
    KeyUsage: Certificate Sign, CRL Sign
    SubjectKeyIdentifier: Auto-generated
```

#### Certificate Policy
```json
{
  "keyProperties": {
    "keyType": "RSA-HSM",
    "keySize": 4096,
    "reuseKey": false,
    "exportable": false
  },
  "certificateProperties": {
    "certificateType": "RootCA",
    "subject": "CN=Company Root CA, O=Company Australia, C=AU",
    "validity": {
      "validityInMonths": 240
    }
  }
}
```

### Day 8-9: Configure CRL Distribution Points

#### Azure Storage Configuration
- Storage Account: `pkicrlstorageaus`
- Replication: Geo-redundant (GRS)
- Container: `crl` (public access)
- Backup: Australia Southeast region

#### CDN Setup for Global Distribution
```yaml
CDN Profile:
  Name: PKI-CDN-Australia
  SKU: Standard Microsoft
  Endpoints:
    - crl.company.com.au
    - ocsp.company.com.au
  Origin: pkicrlstorageaus.blob.core.windows.net
  Caching: 4 hours
  Geo-filtering: None (global access)
```

#### CRL Publishing Schedule
- Base CRL: Every 7 days
- Delta CRL: Every 24 hours
- CRL overlap: 10% (16.8 hours for weekly)
- CDP URLs:
  - Primary: `http://crl.company.com.au/root.crl`
  - Backup: `http://crl-backup.company.com.au/root.crl`

### Day 10: Backup and Disaster Recovery

#### Backup Configuration
```yaml
Recovery Services Vault:
  Name: RSV-PKI-AustraliaEast
  Location: Australia East
  Backup Items:
    - Azure Key Vault (daily)
    - CA configuration (daily)
    - Certificate database (hourly)
  Retention:
    Daily: 30 days
    Weekly: 12 weeks
    Monthly: 12 months
    Yearly: 10 years
```

#### Disaster Recovery Plan
- **RPO**: 1 hour for certificate data
- **RTO**: 4 hours for critical services
- **Failover Region**: Australia Southeast
- **DR Testing**: Quarterly
- **Runbook Location**: Azure Automation Account

## Validation Checklist

### Infrastructure Validation
- [ ] All resource groups created and tagged
- [ ] RBAC roles assigned correctly
- [ ] Virtual network and subnets configured
- [ ] NSG rules applied and tested
- [ ] ExpressRoute/VPN connectivity established

### Key Vault Validation
- [ ] Key Vault deployed with HSM
- [ ] Access policies configured
- [ ] Audit logging enabled
- [ ] Backup configured and tested
- [ ] Private endpoint configured

### Root CA Validation
- [ ] Root CA certificate generated
- [ ] Certificate chain validates correctly
- [ ] CRL accessible from internet
- [ ] CDP URLs resolve correctly
- [ ] CA backup completed successfully

## Success Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| Infrastructure deployment time | 5 days | - |
| Network latency to on-premises | < 10ms | - |
| Key Vault availability | 99.99% | - |
| CRL download time | < 500ms | - |
| Backup success rate | 100% | - |

## Risk Mitigation

| Risk | Mitigation Strategy | Status |
|------|-------------------|---------|
| Azure service outage | Multi-region deployment | Configured |
| Network connectivity loss | ExpressRoute + VPN backup | Active |
| Key compromise | HSM protection, audit logging | Implemented |
| Configuration drift | Azure Policy, ARM templates | Enforced |
| Unauthorized access | RBAC, PIM, MFA | Enabled |

## Phase 1 Deliverables

1. **Documentation**
   - Network architecture diagram
   - Security baseline document
   - Operational runbook
   - Disaster recovery plan

2. **Technical Assets**
   - Azure infrastructure (IaC templates)
   - Root CA certificate
   - CRL distribution points
   - Monitoring dashboards

3. **Approvals Required**
   - Security team sign-off
   - Network team validation
   - Compliance review
   - Management approval for Phase 2

## Next Steps

Upon successful completion of Phase 1:
1. Schedule Phase 2 kick-off meeting
2. Provision subordinate CA infrastructure
3. Begin AD CS deployment planning
4. Coordinate with application teams for integration requirements

---

[← Previous](04-key-components.md) | [Index](00-index.md) | [Next →](06-phase2-core-infrastructure.md)