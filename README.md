## Table of Contents
  - [Overview](#overview)
  - [To Start](#to-start)
  - [Status](#status)
  - [Cucumber](#cucumber)
  - [VS Code](#vs-code)
  - [Node JS](#node-js)
  - [Categories](#categories)
    - [Functional](#functional)
    - [Integration](#integration)
    - [Acceptance](#acceptance)
  - [Wiremock](#wiremock)
  - [Features](#features)
  - [Npm](#npm)
  - [View Reports](#view-reports)
  

## Overview
Test [Features](./features/) are written in [Cucumber](#cucumber) by [Categories](#categories) with IDE [VS Code](#vs-code) and [Npm](#npm) run on [Node JS](#node-js) with [Wiremock](#wiremock) Mock Service

## To Start
1. Install **PowerShell 7**
    - https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.5
    
2. Install **Node JS**
    - nvm
      - [INSTALL-NVM.md](./INSTALL-NVM.md)
      - (https://github.com/coreybutler/nvm-windows/releases)
        - Assests - `nvm-setup.exe`
        - `nvm install 22.22.0`
        - `nvm use 22.22.0`
        
    -OR-
    
    - (https://nodejs.org/en/download) `V22.22.0 (LTS)` `(.msi)`
      - Note. Turn Off Visual Studio before installing native
      
    - This will install Node JS and NPM
    
    - After install Check Version `node -v` `npm -v`
    - 
      ```
      PS C:\Dev\AS\GitHub\qa-aam\Tests\Services> node -v; npm -v
        v22.22.0
        11.11.0
      ```
      
3. Clone this **Project**.
    - https://github.com/AirStripTech/qa-aam 
    
4. Get to and Review **Services Test Dir**
    - [Tests/Services](./)
    
5. Review **NPM**
    - `package.json` `scripts`
    - [Tests/Services/package.json](./package.json)
    
6. Clean **Packages**
    - `npm run del:packages` 
    
7. Install **Packages**
    - `npm ci`
    
8. Inatall **JAVA** 
    - **JDK 25** for **WireMock**
    - https://www.oracle.com/java/technologies/downloads/#jdk25-windows
    - Set up `JAVA_HOME` and `Path`
    
9. Check **JAVA** 
    - `java -version`
    
10. Start **WireMock**
      ```
      PS C:\Dev\AS\GitHub\qa-aam\Tests\Services\wireMock> .\npx-wiremock.bat
      ```
      
11. Check **WireMock**
    - [Tests/Services/wireMock/wiremock-health-check.ps1](./wireMock/wiremock-health-check.ps1)
    - `PowerShell` `wiremock-health-check.ps1`
    -
      ```
      PS C:\Dev\AS\GitHub\qa-aam\Tests\Services> .\wireMock\wiremock-health-check.ps1
        {
          "Port": 9999,
          "Process": {
            "PID": 31780,
            "Name": "java",
            "Memory": "128 MB",
            "CPU_s": 1.8,
            "User": "AIRSTRIPTECH\\andytang",
            "Status": "Healthy"
          },
          "Health": {
            "status": "healthy",
            "message": "Wiremock is ok",
            "version": "3.13.2",
            "uptimeInSeconds": 46,
            "timestamp": "2026-03-05T06:16:09.478936800Z"
          }
        }
      ```
      
12. Update **Flight Manager Service Config** to use mock
    - `url: 'http://localhost:9999'`
    - Ref.
      - `mt002acmsvm.airstrip.tech` - `C:\Airstrip\acms\FlightManager\appsettings.json`
      - [Tests/Services/data/env/devops02/tools/flight-manager-config.ps1](./data/env/devops02/tools/flight-manager-config.ps1)
    
13. Create / Update **Test Config**
    - [Tests/Services/config/env/local.api.conf.js](./config/env/local.api.conf.js)
      - `Tests/Services/config/env/local.[atang].api.conf.js`
      - Ref. [Tests/Services/config/env/local.devOps.02.api.conf.js](./config/env/local.devOps.02.api.conf.js)
      
14. Run **Test**
    - `PowerShell`
    - [Tests/Services/run-tests.ps1](./run-tests.ps1)
    - `PS C:\Dev\AS\GitHub\qa-aam\Tests\Services> clear; npm run reports:clear;.\run-tests.ps1 devOps.02 acceptance/client-air-command-web-socket-get-flights`
    - `[PowerShell][Test Dir]` `[Clear View];` `[Clear Report];` `[Run Test] [by Env] [Test Feature File]`
    - Ref. [ReadMe - Run Tests](./README.md#run-tests)
    
15. Review **Test Results**
    - `npm run reports`

## Status
| Activity | Status |
| :------ | :----- |
| AAM - Env 02 - Env Setup | [![AAM - ENV02 - Environment Setup](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-setup.yml/badge.svg)](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-setup.yml) |
| AAM - Env 02 - Test - Functional | [![AAM - ENV02 - Test - Functional](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-functional.yml/badge.svg)](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-functional.yml) |
| AAM - Env 02 - Test - Accetpance | [![AAM - ENV02 - Test - Acceptance](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-acceptance.yml/badge.svg)](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-acceptance.yml) |
| AAM - Env 02 - Test - Functional - Local | [![AAM - ENV02 - Test - Functional - Local](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-local-functional.yml/badge.svg)](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-local-functional.yml) |
| AAM - Env 02 - Test - Acceptance - Local | [![AAM - ENV02 - Test - Acceptance - Local](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-local-acceptance.yml/badge.svg)](https://github.com/AirStripTech/qa-aam/actions/workflows/devops-env-atc02-local-acceptance.yml) |
| AAM - Env 02 - Test Report Page| [![pages-build-deployment](https://github.com/AirStripTech/qa-aam/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/AirStripTech/qa-aam/actions/workflows/pages/pages-build-deployment) |
| Server AAM - CI | [![Server AAM - CI](https://github.com/AirStripTech/server-aam/actions/workflows/ci.yml/badge.svg)](https://github.com/AirStripTech/server-aam/actions/workflows/ci.yml) |

## Cucumber
- Test Syntax - [Cucumber Overview](https://cucumber.io/docs/guides/overview/) 
- Test Runner - [Cucumber JS](https://www.npmjs.com/package/@cucumber/cucumber)

## VS Code
- Download and Install https://code.visualstudio.com/
- [Recommended VS Code extensions](./.vscode/extensions.json)
- [WORKSPACE](./acms-tests.code-workspace)

## Node JS
Download and Install
https://nodejs.org/en/download
- `V22.22.0 (LTS)` `(.msi)`

## Categories

### Functional

- To assure each service and api works 

### Integration

- To assure services are setup to work together


### Acceptance

- To assure services work together for product scenarios 

## Wiremock

https://wiremock.org/docs/

### Local - docker wiremock 
- [run-wiremock-docker.ps1](./wireMock/run-wiremock-docker.ps1)
   - Docker: https://hub.docker.com/r/wiremock/wiremock
   - Wiremock Health -- `curl --location 'http://localhost:9999/__admin/health'`

### Local - npm wiremock
- npm installed WireMock (https://www.npmjs.com/package/wiremock)
- the data and mappings can be found in the [wireMock folder](./wireMock/).

### Test Machine
[PM2](https://pm2.keymetrics.io/docs/usage/quick-start/) run WireMock manually on the Test Machine 

e.g. on `DevOps 02` `app-host-01.airstripdev.com` 
- [AirStrip - Wiki - ATC - Test Machines](https://airstrip.atlassian.net/wiki/x/AwB9ww)
- Run PowerShell as Admin `PS C:\wiremock> pm2 start .\start-npx-wiremock-bat.js --name WireMock`
  - PM2 source is at (`C:\etc\pm2`) and it is npm installed globally 
  - Tests source is at (`C:\artifacts\cd\Tests\wireMock`)

### Mock Data
Mapping document priorities are reserved as follows:

- priority **90+** for manual mock data mapping files in /tools/wireMock folder.
- priority **80-89** for functional test global mappings that will be available throughout the functional test run
- priority **50-79** for functional test dynamic mappings that can be created/deleted as individual scenarios require

## Features

| **Feature**                                 | **Purpose**                                                                   |
| ------------------------------------------- | ----------------------------------------------------------------------------- |
| [Functional](./features/functional/)   | [Categories - Functional Tests](#functional)   |
| Integration n/a | [Categories - Integration Tests](#integration) |
| [Acceptance](./features/acceptance/)   | [Categories - Acceptance Tests](#acceptance)   |

### Test Folder Structure

| **Folder**                   | **Purpose**                                                                  |
| ---------------------------- | ---------------------------------------------------------------------------- |
| [config](./config/)     | Test Environment Configs                                                     |
| [data](./data/)         | Test Data e.g. Dynamic WireMock Data                                         |
| [features](./features/) | Cucumber Scenarios / Test Cases                                              |
| [helpers](./helpers/)   | Classes to support running tests e.g. RestClient, Services, Verifiers        |
| [steps](./steps/)       | Cucumber Steps                                                               |

## Npm

`scripts` in [package.json](./package.json)

### Install

```cmd
npm install
```

### Lint

```cmd
npm run lint
```

### Run Tests

for env in [config/env](./config/env)

on PowerShell

**Run all tests** on env devOps.02

```ps
.\run-tests.ps1 devOps.02
```

On PowerShell, it may pipe commands.
  - **Clear Reports** and **Run Test** `features\acceptance\flight.feature` on `devOps 02 Environment`

    ``` ps
    npm run reports:clear; .\run-tests.ps1 devOps.02 acceptance\flight
    ```

Based on `function features()` in [config/api-test.js](./config/api-test.js) it may

- **Run a feature**
  
  e.g. `features\functional\api\recipientsService\recipients\contexts\get.feature`

    ```
    .\run-tests.ps1 local contexts\get
    ```
    -or-

    ```
    .\run-tests.ps1 local features\functional\api\recipientsService\recipients\contexts\get.feature
    ```

- **Run features**
  - `features\functional\api\recipientsService\`
    
    ```
    .\run-tests.ps1 local **\recipientsService\
    ```
  - Run All Functional Tests
    ```
    .\run-tests.ps1 local features\functional\**\*.feature
    ```
  - Run All Acceptance Tests
    ```
    .\run-tests.ps1 local features\acceptance\**\*.feature
    ```
      

### View Reports
- #### **Local Test Run Reports** 
  ```cmd
  npm run reports
  ```

- #### **GitHub Test Run Reports**
  
  Switch to Git Branch `gh-pages` (https://github.com/AirStripTech/qa-aam/tree/gh-pages)

  e.g. 
  to view 
  - `Test Run #60`(https://github.com/AirStripTech/qa-aam/actions/runs/17213217154) 
    - `Report`(https://github.com/AirStripTech/qa-aam/tree/gh-pages/60), matched the by the Run Id `#60`

  ```cmd
  C:\Dev\AS\GitHub\qa-aam\Tests\Services> npx allure open ..\..\60\
  ```

- #### **GitHub Test Run Reports - Artifacts**

  1. Download Test Reports from the Artifacts
  2. Using Node.js
  3. Make sure Node.js is installed (node -v to check).
  4. Install a simple static server (if you don’t have it):
  5. `npm install -g serve`
  6. From the report folder, start the server:
     ```
     cd C:\Users\andytang\Downloads\allure-report_31
     serve .
     ```
# powershell
