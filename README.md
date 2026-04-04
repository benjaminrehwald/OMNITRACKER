# OMNITRACKER ITSM Customization

A structured collection of scripts, workflows, service catalog definitions, and documentation
for a modern, scalable OMNITRACKER ITSM implementation aligned with ITIL best practices.

## Repository Structure

```
OMNITRACKER/
├── docs/
│   ├── architecture.md          # Overall system architecture and design decisions
│   ├── service-catalog.md       # Service catalog design and usage guide
│   └── itil-processes.md        # ITIL process descriptions and separation
├── scripts/
│   ├── incident/
│   │   ├── auto-routing.vbs     # Automatic routing based on category/symptom
│   │   ├── auto-assignment.vbs  # Group/agent assignment logic
│   │   └── escalation.vbs       # SLA-based escalation
│   ├── service-request/
│   │   ├── approval-workflow.vbs    # Multi-level approval handling
│   │   └── fulfillment-routing.vbs  # Route SR to fulfillment group
│   ├── change/
│   │   ├── cab-notification.vbs # CAB member notification
│   │   └── change-approval.vbs  # Change approval state machine
│   └── common/
│       ├── mail-templates.vbs   # Shared e-mail template helpers
│       └── utility-functions.vbs # Shared utility functions
├── catalog/
│   ├── service-catalog.json     # Service catalog item definitions
│   └── categories.json          # Category tree for Incident/SR/Change
└── workflows/
    ├── incident-workflow.md         # Incident lifecycle description
    ├── service-request-workflow.md  # Service Request lifecycle description
    └── change-workflow.md           # Change lifecycle description
```

## Key Design Principles

1. **Process Separation** – Incidents, Service Requests, and Changes are clearly separated
   objects with distinct workflows, SLAs, and routing rules.
2. **Service Catalog Driven** – All Service Requests are created from catalog items;
   routing, approval chains, and fulfillment groups are defined per service.
3. **Automation First** – Routing, assignment, notifications, and escalations are
   automated via event scripts; manual steps are reduced to the minimum required.
4. **Scalable Category Model** – A three-level category tree
   (Domain → Category → Symptom/Service) scales to 500+ services without
   performance degradation.
5. **Maintainability** – All scripts share a common utility library; magic strings
   are replaced with named constants defined in a single place.

## Getting Started

1. Review `docs/architecture.md` for the overall design.
2. Import `catalog/categories.json` into the OMNITRACKER Category object.
3. Import `catalog/service-catalog.json` into the Service Catalog object.
4. Deploy scripts from `scripts/` to the corresponding OMNITRACKER Script objects
   (see inline comments for the correct event hook).
5. Refer to `workflows/` for state machine diagrams and transition conditions.

## Requirements

- OMNITRACKER 6.x or later
- VBScript runtime (built into Windows / OMNITRACKER server)
- OMNITRACKER Application Server with Scripting Module enabled
