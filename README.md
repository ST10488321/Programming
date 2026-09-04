## 1. System Overview

**RaceDay** is a full-stack web-based event management system designed specifically for the South African road running, walking, and cycling community. The platform bridges the gap between Event Organisers and Participants by digitising the entire event lifecycle—from registration and category management to result capturing and performance tracking.

South Africa hosts hundreds of community walks, park runs, and charity cycling events every weekend. Despite the massive participation, many events still rely on paper-based registration, spreadsheets, and disconnected communication channels. RaceDay solves this by providing a centralised, cloud-aware platform that streamlines event management, improves participant experience, and provides organisers with real-time data insights.

This repository contains **Part 1** of the project, which focuses on **System Planning and Database Design**. No application code (C#/ASP.NET) has been written yet—this document serves as the blueprint for the API development in Part 2 and the MVC frontend in Part 3.

---

## 2. User Roles

The RaceDay system supports two distinct user roles. Role-based access is enforced at the API level (Part 2) and reflected consistently in the MVC interface (Part 3).

### 2.1 Organiser
- **Description:** The event creator and manager. Organisers are responsible for the administrative and operational aspects of events.
- **Permissions:**
  - Create, edit, and delete events.
  - Define age or distance categories for each event.
  - View all enrolments for events they created.
  - Capture finish times and finishing positions for participants.
  - Manage event details (name, description, date, location, distance, and event type).

### 2.2 Participant
- **Description:** The end-user who registers to take part in events. Participants are the primary consumers of the platform.
- **Permissions:**
  - Register an account and log in.
  - Browse upcoming events.
  - Enter an event by selecting a specific category.
  - View their own enrolment history.
  - Track their personal results and performance history.

---

## 3. Project Structure

Below is the folder structure for this repository. All planning documents are stored inside the `/docs` folder.

```plaintext
PROG6212_POE_Part1/
│
├── .github/
│   └── workflows/
│       └── ci.yml                          # GitHub Actions CI/CD pipeline
│
├── docs/
│   ├── ERD.png                             # Entity Relationship Diagram (PNG/PDF)
│   ├── endpoints.md                        # API Endpoint Plan (Markdown/PDF)
│   └── schema.sql                          # SQL Database Script
│
├── README.md                               # This file
└── .gitignore                              # Git ignore rules
