# Managing Splunk Cloud Victoria with automation

### Platform Requirements
- Splunk Enterprise Dev/Test License
- Splunk Enterprise, full install standalone, linux
- Splunk Cloud Victoria version minimum 9.2.2304
- The API opened to Splunk Cloud, (via support case)

### Admin user requirements
- Splunk Cloud sc_admin or equivalant admin account, with Export Apps role added to ALL Search Head Groups
- Not be restricted by admin
- https://docs.splunk.com/Documentation/SplunkCloud/9.2.2406/Admin/SelfServiceAppInstall#Install_restricted_Splunkbase_apps

### Add Development Reference Documentation

- https://dev.splunk.com/enterprise/docs/developapps
- https://dev.splunk.com/enterprise/tutorials/module_getstarted

### Splunk Platform Required Knowledge 
- Roles, Capabilites, Users, and Knowledge Object management
- Knowledge Object precedence
- Do NOT modify or use Splunk system roles or user in Cloud
- Define all KO permissions in ./metadata/default.meta

### Splunk Cloud Victoria - Required Knowlege

**1. Differences between Enterprise and Cloud**
https://docs.splunk.com/Documentation/SplunkCloud/9.2.2406/Service/SplunkCloudservice#Differences_between_Splunk_Cloud_Platform_and_Splunk_Enterprise
- Real time searches are enabled by default in Victoria Cloud

- API differences
  - https://docs.splunk.com/Documentation/SplunkCloud/9.2.2406/RESTTUT/RESTandCloud
  - **Cloud REST API** is a subset of the **Enterprise REST API**, have different endpoints and capabilities.
  - https://docs.splunk.com/Documentation/SplunkCloud/9.2.2406/RESTTUT/RESTandCloud#REST_API_access_limitations
  - **Rest API** requires a `support case` to open the port and enable
  - Cloud REST API is a subset of the Enterprise REST API, have different endpoints in some cases.
    
- Federated Search Splunk to Splunk
-  Transparent mode


**2. How self-service app installation works in Victoria Experience**

> https://docs.splunk.com/Documentation/SplunkCloud/9.2.2406/Admin/PrivateApps#How_self-service_app_installation_works_in_Victoria_Experience

- App Vetting requires all content be **merged** to `/default/` to pass
- Install and Uninstall does not allow you to target a specific environment for app install/update.
- All apps are installed to all search heads (Adhoc and ES)
- App default content will be replicated to both (Adhoc and ES)
- Enabled `saved searches` on install will run on `all search heads` (Adhoc and ES)
- Apps with any Knowledge Objects without explicit ownership will be a default role of nobody

#### How to Manage Lookups in Victoria Splunk Cloud 

> https://docs.splunk.com/Documentation/SplunkCloud/9.2.2406/Admin/PrivateApps#Lookup_file_behavior_during_app_upgrade_on_Victoria_Experience
- Do not upload **Lookup definition** CHANGES/UPDATES to columns of names via App/ACS
- Lookup defintions cannot be modified after app install progamatically, Lookup Editor in GUI is current process

#### How to Manage Data Models in Victoria Splunk Cloud 
- Data Model definitions that override the `Splunk_SA_CIM` will not be setup to allow shared data model summaries.

3. ACS capabilites
> https://docs.splunk.com/Documentation/SplunkCloud/9.2.2406/Config/RBAC#Manage_ACS_endpoint_access_with_capabilities
- Any user whose role contains the required capabilities can run operations against ACS API endpoints, not just the sc_admin

#### Admin Config Service (ACS) API endpoints reference

> http://docs.splunk.com/Documentation/SplunkCloud/latest/Config/ACSREF

#### ACS on CLI 
http://docs.splunk.com/Documentation/SplunkCloud/latest/Config/ACSCLI

**4. Target Apps ACS Capabilities/Limitations**

> https://docs.splunk.com/Documentation/SplunkCloud/9.2.2403/Config/TargetSearchHeads
- ACS can only target individual SH with limited capabilities (not install or uninstall) permissions is relevant
- Anyone with the needed permissions can use ACS capabilities not just sc_admin
  
** 5. How to Export Apps, by Search Head group**

> https://docs.splunk.com/Documentation/SplunkCloud/9.2.2403/Config/ExportApps

- Export App capability is only available in `9.2.2304` and higher
- Export App IS targeted to a Search Head Server Group
- Export App is restricted to custom apps only, but you can get `.apps/defaut`, `.apps/local`, `./users/default` , `./users/local`
- Local Content can only be Exported from **private** customer apps, and the search app.
- Local Content in Splunkbase/Splunk restricted apps requie a support case to retrieve files.
- Content shared via replicated victoria app, will be accessible by the sc_admin of that search head group

### Impact

- User and Content Management Goverance of the Splunk Cloud as a unified platform is critical
- Least privledged RBAC and explicit knowledge object ownership and permissions is a must for platform stability
- Must be careful to not run all searches enabled twice, by restricting content with explicit roles
- Use of Splunk system accounts allows other admins access to KOs and replication to other search head server groups
