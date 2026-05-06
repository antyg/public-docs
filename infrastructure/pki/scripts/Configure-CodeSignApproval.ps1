# Configure-CodeSignApproval.ps1
# Implements approval workflow for code signing requests

# Create approval database
Invoke-SqlCmd -ServerInstance "SQL-PKI-DB" -Query @"
CREATE DATABASE CodeSignApprovals;
GO

USE CodeSignApprovals;
GO

CREATE TABLE SigningRequests (
    RequestId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    RequestDate DATETIME2 DEFAULT GETUTCDATE(),
    Requester NVARCHAR(100) NOT NULL,
    FileName NVARCHAR(500) NOT NULL,
    FileHash NVARCHAR(64) NOT NULL,
    Purpose NVARCHAR(1000),
    ApprovalStatus NVARCHAR(20) DEFAULT 'Pending',
    Approver NVARCHAR(100),
    ApprovalDate DATETIME2,
    RejectionReason NVARCHAR(1000),
    SigningDate DATETIME2,
    CertificateSerial NVARCHAR(100),
    INDEX IX_RequestDate (RequestDate),
    INDEX IX_Requester (Requester),
    INDEX IX_Status (ApprovalStatus)
);

CREATE TABLE ApprovalRules (
    RuleId INT IDENTITY PRIMARY KEY,
    RuleName NVARCHAR(100),
    FilePattern NVARCHAR(500),
    RequesterPattern NVARCHAR(100),
    AutoApprove BIT DEFAULT 0,
    RequiredApprovers INT DEFAULT 1,
    ApproverGroup NVARCHAR(100),
    MaxFileSize BIGINT,
    IsActive BIT DEFAULT 1
);

-- Insert default rules
INSERT INTO ApprovalRules (RuleName, FilePattern, RequesterPattern, AutoApprove, RequiredApprovers, ApproverGroup)
VALUES
    ('PowerShell Scripts', '%.ps1', '%', 0, 1, 'CodeSign-Approvers'),
    ('Production Executables', '%.exe', '%', 0, 2, 'CodeSign-Managers'),
    ('Test Builds', '%test%.exe', 'DEV-%', 1, 0, NULL),
    ('Driver Packages', '%.sys', '%', 0, 2, 'Security-Team');
"@

# Create Power Automate flow for approval
$approvalFlow = @{
    Name    = "Code Signing Approval Flow"
    Trigger = "When a new item is created in SigningRequests"
    Actions = @(
        @{
            Type  = "GetApprovalRules"
            Query = "SELECT * FROM ApprovalRules WHERE @FileName LIKE FilePattern"
        },
        @{
            Type = "Condition"
            If   = "AutoApprove = 1"
            Then = @{
                Type     = "UpdateStatus"
                Status   = "Approved"
                Approver = "System-Auto"
            }
            Else = @{
                Type    = "SendApprovalEmail"
                To      = "ApproverGroup"
                Subject = "Code Signing Request: @FileName"
                Body    = "Please review and approve the code signing request"
            }
        },
        @{
            Type    = "WaitForApproval"
            Timeout = "24 hours"
        },
        @{
            Type   = "UpdateDatabase"
            Fields = @("ApprovalStatus", "Approver", "ApprovalDate")
        },
        @{
            Type          = "NotifyRequester"
            EmailTemplate = "ApprovalDecision"
        }
    )
}

Write-Host "Approval workflow configured" -ForegroundColor Green
