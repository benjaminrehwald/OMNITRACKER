# Service Catalog Design & Usage Guide

## 1. Purpose

The Service Catalog is the single source of truth for all requestable IT services.
Each catalog item defines:
- What the service is (description, SLA)
- Who can request it (eligibility)
- Who fulfills it (fulfillment group)
- Whether approval is needed (and who approves)
- What information is collected at request time (form fields)

## 2. Catalog Item Data Model

```
ServiceCatalogItem {
    ID               : String        // Unique identifier, e.g. "SVC-NET-001"
    Name             : String        // Display name
    Description      : String        // What the service does
    Category         : Reference     // → Category object (Level 3)
    ServiceOwner     : Reference     // → Person/Group responsible
    FulfillmentGroup : Reference     // → Assignment group
    SLA_Hours        : Integer       // Business hours to fulfill
    ApprovalRequired : Boolean
    ApprovalLevel    : Integer       // 1 = line manager only; 2 = + IT approval
    ApproverGroup    : Reference     // Fallback approver group
    CostCenter       : Boolean       // Require cost center field
    FormTemplate     : String        // Name of custom form template
    Active           : Boolean       // Visible in catalog?
    Tags             : String[]      // Search tags
}
```

## 3. Catalog Structure (Domain → Category → Service)

### IT Infrastructure

| ID           | Service Name                | Fulfillment Group | SLA (h) | Approval |
|--------------|-----------------------------|-------------------|---------|----------|
| SVC-NET-001  | VPN Account Setup           | Network Team      | 8       | No       |
| SVC-NET-002  | Network Port Activation     | Network Team      | 16      | No       |
| SVC-SRV-001  | New Virtual Server          | Server Team       | 40      | Yes (L2) |
| SVC-SRV-002  | Server Storage Extension    | Server Team       | 16      | Yes (L1) |
| SVC-SRV-003  | Server Decommission         | Server Team       | 40      | Yes (L2) |

### End-User Computing

| ID           | Service Name                | Fulfillment Group | SLA (h) | Approval |
|--------------|-----------------------------|-------------------|---------|----------|
| SVC-EUC-001  | New Laptop Setup            | Workplace Team    | 40      | Yes (L1) |
| SVC-EUC-002  | Software Installation       | Workplace Team    | 8       | No       |
| SVC-EUC-003  | Mobile Device Setup         | Workplace Team    | 16      | Yes (L1) |
| SVC-EUC-004  | Printer Setup               | Workplace Team    | 8       | No       |

### Business Applications

| ID           | Service Name                | Fulfillment Group | SLA (h) | Approval |
|--------------|-----------------------------|-------------------|---------|----------|
| SVC-SAP-001  | SAP Role Request            | SAP Team          | 16      | Yes (L2) |
| SVC-SAP-002  | SAP Password Reset          | SAP Team          | 4       | No       |
| SVC-M365-001 | Microsoft 365 License       | M365 Team         | 8       | Yes (L1) |
| SVC-M365-002 | Shared Mailbox Creation     | M365 Team         | 8       | No       |
| SVC-M365-003 | Teams Channel Setup         | M365 Team         | 4       | No       |

### Access & Identity

| ID           | Service Name                | Fulfillment Group | SLA (h) | Approval |
|--------------|-----------------------------|-------------------|---------|----------|
| SVC-IAM-001  | New User Account            | IAM Team          | 8       | Yes (L2) |
| SVC-IAM-002  | Account Modification        | IAM Team          | 4       | Yes (L1) |
| SVC-IAM-003  | Account Deactivation        | IAM Team          | 4       | Yes (L1) |
| SVC-IAM-004  | Privileged Access Request   | IAM Team          | 16      | Yes (L2) |
| SVC-IAM-005  | Password Reset              | Service Desk      | 1       | No       |

## 4. Approval Levels

| Level | Meaning                                  | Approver                         |
|-------|------------------------------------------|----------------------------------|
| L1    | Single approval                          | Line Manager of requester        |
| L2    | Two-stage approval                       | L1 + IT Service Owner / ApproverGroup |
| L3    | Three-stage approval (high-risk/cost)    | L1 + IT Service Owner + CISO / L3ApproverGroup |

Approval timeouts (no response within N hours) escalate to the next approver in the chain
and notify the `ApproverGroup` as fallback.

## 5. Catalog Lifecycle Management

1. **New service**: IT Service Owner submits a Change (CHG) to add the catalog item.
   After CAB approval the item is set `Active = true`.
2. **Service modification**: Minor changes (SLA, group) via Change (Standard).
   Major changes (form, approval chain) via Change (Normal) with CAB review.
3. **Service retirement**: Item is set `Active = false`; open SRs are migrated.

## 6. UX Guidelines for End Users

- Catalog is searchable by keyword and filterable by domain.
- Each item shows: expected fulfillment time, what to provide, whom to contact.
- Users see only services they are eligible for (based on AD group / department).
- After submission users receive an auto-confirmation mail with SR number and SLA deadline.
