# Gmail Token & Job Fetch PowerShell Project

## Overview

This project aims to:

1. Create a Gmail OAuth token for a user account.
2. Use the token to fetch Gmail messages for job applications.
3. Deduplicate job listings or related emails.

The solution is implemented in **PowerShell** and uses **Google API NuGet packages**.

---

## Stage 0: Install Google API Packages

The goal of this stage was to install all required Google API NuGet packages for PowerShell:

- `Google.Apis`
- `Google.Apis.Core`
- `Google.Apis.Auth`
- `Google.Apis.Gmail.v1`

**Status:** ❌ Deprecated

**Reason:**  
Installing these packages via PowerShell consistently failed due to dependency issues:

WARNING: ⚠ Failed to install Google.Apis.Core: Unable to find dependent package(s) (System.Reflection.Extensions)


Other attempts to install packages, including forcing versions, running as administrator, and flexible versioning, were not reliable.  
Because of these unresolved package issues, we paused this approach.

**Alternative approach:**  
We are considering **TypeScript / Node.js / npm** for long-term maintainability, easier dependency management, and cross-platform compatibility.

---

## Stage 1: Create Gmail OAuth Token

This stage would:

1. Load Google API DLLs from installed NuGet packages.
2. Run OAuth flow to generate Gmail token (`gmail_token.json`).
3. Log safe credential info (user ID, token expiry, token length).
4. Copy the token to a script-friendly path (or symlink).

**Status:** ⏸ Paused  
Cannot proceed without Stage 0 successfully installing packages.

---

## Stage 2: Fetch Gmail Messages & Remove Duplicates

This stage would:

1. Use the Gmail API token to fetch emails.
2. Deduplicate messages.
3. Provide output for job applications tracking.

**Status:** ⏸ Paused  
Depends on Stage 1 completion.

---

## Current Notes

- PowerShell approach is self-contained but requires complex package management.
- Package dependencies and DLL loading are fragile, especially on Windows.
- TypeScript / npm approach may provide a more robust long-term solution.
- The project may resume once a reliable package installation or alternative stack is in place.

---

## Suggested Next Steps

1. Consider switching to **TypeScript / Node.js** for Gmail API integration.
2. Implement token creation, message fetching, and deduplication in that environment.
3. Reuse existing logic and config structure (`gmail-api.config.json`) from PowerShell scripts.
