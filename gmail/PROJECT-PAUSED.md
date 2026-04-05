# Gmail Token & Job Fetch PowerShell Project (Paused)

## Project Overview

This project aims to:

1. Create a Gmail OAuth token.
2. Fetch Gmail messages for job applications.
3. Deduplicate job listings/emails.

⚠ **Status:** Paused due to package installation issues in PowerShell.

---

## Workflow Diagram

```text
Stage 0 ──► Stage 1 ──► Stage 2
Install      Create       Fetch &
Packages     OAuth Token  Deduplicate
 (NuGet)      (gmail_token.json)