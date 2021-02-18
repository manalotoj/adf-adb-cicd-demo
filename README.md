# adf-adb-cicd-demo
An example of Azure DevOps yaml pipelines for Data Factory and Databricks

## Repo Contents
### ./deployment folder
Contains yaml templates, powershell scripts, and arm templates that are intended to be reused for every application's CICD pipelines.

#### yamlTemplates folder
Contains Azure DevOps yaml templates.
##### Databricks Templates
- adb_build.yml - common build tasks that copies notebooks and publishes them as a build artifact.
- adb_deploy.yml - deploys build artifact to a Databricks workspace.
##### ADF Templates
- adf_build.yml - common build tasks that copies ADF templates and publishes them as a build artifact.
- adf_deploy.yml - tasks that deploy ADF templates. Includes pre and post-deployment tasks to stop and start triggers, as well as an option to grant permissions to a shared integration runtime.

#### scripts folder
- adf-triggers.ps1 - powershell script, copied directly from [pre and post-deployment script](https://docs.microsoft.com/en-us/azure/data-factory/continuous-integration-deployment#script), that stops and starts triggers.
- adf_shared_ir.ps1 - powershell script to grant permissions to a shared, self-hosted, integration runtime. Note that the service principal must have elevated permissions in order to create role assignment(s).
#### armTemplates folder
ARM template to create a plain vanilla ADF instance. This can be used when first creating a non-dev/non git integrated ADF instance.

### ./azure-pipelines folder
Contains sample azure pipelines that use the common components within the *deployment* folder.

## How to implement CICD for a given application
### Prerequisites
1. An Azure DevOps project
2. An Azure subscription
3. An ARM service connection for the Azure subscription. The service principal must have permissions to create resource groups and data factory instances (if they do not already exist). If using script to grant permissions to shared integration runtime, service principal must have permissions to create role assignments.

### Step 1: Create a repository named "deployment"
Store the contents of the ./deployment folder in this repository. Copy only the contents and not the parent folder. If you change the repository name, then you must also change how the repository is referenced within the sample pipelines.

### Step 2: Create a repository for your application
Create a repository for your application. Create the following root level folders:
- adb-root - use for all databricks folders and notebooks
- adf-root - use as the path when establishing the git integration of your dev data factory.

### Step 3: ADF git integration
Enable git integration in your dev data factory. Specify adf-root for the path. Leave all else as default.

### Step 4: Create a common ADF Instance (optional)
Create a common ADF instance to house shared integration runtime(s). The above example only uses a single IR but can be modified to accommodate multiple shared IRs. Authorize ADF in step 3 to use shared IR.

### Step 5: Configure ADF Pipeline
In your app repo:
- temporarily set *adf_publish* branch as the default branch
- within the *adf_publish* branch, create a folder named *azure-pipelines*. Copy the adf-pipeline.yml file into this folder.
- Create a new pipeline using /azure-pipelines/adf-pipeline.yml file from the previous step.
- update the artifact name on line 21
- update *subscriptionConnection* values

Note: subscriptionConnection name values are hard-coded due to a limitation in Azure DevOps.

The sample pipeline uses the following environment and variable group definitions:
- dev_app_001
- uat_app_001

Change these names as appropriate. However, make sure that your variable group names have matching environment names within the yaml pipeline. By convention, deployment stages use variables defined in variable groups.

Once the pipeline is created, set the default branch back to either *master*.

### Step 6: Create variable groups
Define dev_app_001 (using your naming convention of choice) within *Pipelines>Library* and define the following variables:
- adfName - the application adf instance
- region - adf region (ex. 'westus2', 'eastus2', etc.)
- rgName - the resource group that contains the adf
- subscriptionId - subscription Id

If using shared IR, define the following variables:
- commonAdfName - common adf name
- commonRgName - resource group containing the common adf
- sharedIrName - name of shared IR

Optionally, sensitive variables can be associated with a key vault.

Test the pipeline and verify execution. Once successful:
- clone dev_app_001 variable group to define other stages (ex. uat_app_001, prod_app_001)
- modify the values
- within the pipeline, add a section for each stage
- run the pipeline and verify execution

### Step 6: Define deployment approvals and checks
Upon successful execution, environment definitions will automatically be created within *Environments*. For each environment, define approvals and checks as needed (ex. approvals required prior to deploying to UAT and PROD).

### Step 7: Configure ADB Pipeline
In your app repo's master branch:
- create a folder named *azure-pipelines*. Copy the adb-pipeline.yml file into this folder.
- Create a new pipeline using /azure-pipelines/adb-pipeline.yml file from the previous step.
- modify the artifact name on line 18

Navigate to your variable group definitions within *Pipelines>Library* and add the following variables:
- adbWorkspaceUrl
- adbAccessToken - use key vault integration for this variable

Test the pipeline and verify execution.

