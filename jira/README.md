# JIRA Description Check Tool

This script checks JIRA issues for missing or incomplete description data.

---

## Prerequisites

- PowerShell **7.6 or higher** (required)

### Install PowerShell (Windows)

Follow the official Microsoft guide:  
https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.6

Verify installation:

```powershell
$PSVersionTable.PSVersion
```

- Access to a JIRA (Atlassian) project
- JIRA API token

---

## Setup JIRA API Token

1. Generate a JIRA API token from Atlassian:  
   https://id.atlassian.com/manage-profile/security/api-tokens

2. Create a configuration file (example: `jira-config.json`):

```json
{
  "jira": {
    "user": "Your Name",
    "email": "user@email.com",
    "baseUrl": "https://your-project.atlassian.net",
    "token": "your-api-token-here"
  }
}
```

> ⚠️ **Security Note**  
> Do NOT commit this file to source control.  
> Consider storing it outside your repository and creating a symbolic link.

---

## Creating a Symbolic Link (Optional but Recommended)

A symbolic link allows your project to reference the secure token file without storing it directly in the repo.

```powershell
New-Item -ItemType SymbolicLink `
  -Path ".\YHT-JIRA-TOKEN.sym-link.json" `
  -Target "C:\secure\path\jira-config.json"
```

Reference guide: [Microsoft Docs – New-Item: Create symbolic links](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-item)

---

## Usage

Run the PowerShell script with your config file:

```powershell
.\jira-check-description-has-missing-data.ps1 `
  -JiraCredFilePath ".\YHT-JIRA-TOKEN.sym-link.json"
```

---

## Parameters

| Parameter            | Description                          |
|---------------------|--------------------------------------|
| `-JiraCredFilePath` | Path to your JIRA config JSON file   |

---

## Example Workflow

1. Create your secure token file outside the repo
2. Create a symbolic link inside the project (see above)
3. Run the script

---

## Notes

- The script uses JIRA REST API under the hood
- Ensure your account has permission to access the target project/issues
- Token acts as your password — keep it secure

---

## Troubleshooting

**Unauthorized (401)**
- Check your email and API token
- Ensure token is active

**File not found**
- Verify the symbolic link path
- Confirm the target file exists

**Unexpected results**
- Check JIRA issue permissions
- Validate JSON format in config file
