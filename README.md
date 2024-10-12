# tu-ciicd 

Requirements
- Splunk Enterprise Dev/Test License
- Splunk Enterprise, full install standalone, linux
- Splunk Cloud Victoria version minimum 9.2.2304
- Splunk Cloud sc_admin account, with Export Apps role added

Splunk Cloud Victoria - Required Knowlege
# How self-service app installation works in Victoria Experience
https://docs.splunk.com/Documentation/SplunkCloud/9.2.2406/Admin/PrivateApps#How_self-service_app_installation_works_in_Victoria_Experience
- App Vetting requires all content be merged to /default/ to pass
- Install and Uninstall Does not allow you to target a specific environment for app install/update.
- All apps are installed to all search heads (Adhoc and ES)
- App default content will be replicated to both (Adhoc and ES)
- Enabled saved searches on install will run on all search heads (Adhoc and ES)
- Apps with any Knowledge Objects without explicit ownership will be a default role of nobody

# Capabilites of Target Apps ACS
https://docs.splunk.com/Documentation/SplunkCloud/9.2.2403/Config/TargetSearchHeads
- ACS can only target individual SH with limited capabilities (not install) permissions is relevant
  
# How to Export Apps, by Search Head group
https://docs.splunk.com/Documentation/SplunkCloud/9.2.2403/Config/ExportApps
- Export App capability is only available in 9.2.2304 and higher
- Export App is restricted to custom apps only
- Local Content can only be Exported from private customer apps, and the search app.
- Local Content in Splunkbase/Splunk restricted apps requie a support case to retrieve files.

# How to Manage Lookups in Victoria Splunk Cloud  https://docs.splunk.com/Documentation/SplunkCloud/9.2.2406/Admin/PrivateApps#Lookup_file_behavior_during_app_upgrade_on_Victoria_Experience
- Do not upload Lookup definition updates via App
- Lookup defintions cannot be modified after app install progamatically, Lookup Editor in GUI is current process

# How to Manage Data Models in Victoria Splunk Cloud 
- Data Model definitions that override the Splunk_SA_CIM will not be setup to allow shared data model summaries.

# Impact
- User and Content Management Goverance of the Splunk Cloud as a unified platform is critical
- Least privledged RBAC and explicit knowledge object ownership and permissions is a must for platform stability
- Must be careful to not run all searches enabled twice
- Adhoc to ES and ES to Adhoc

# Key Reference Documentation
https://dev.splunk.com/enterprise/docs/developapps

# Getting Started with Splunk App Development
https://dev.splunk.com/enterprise/tutorials/module_getstarted


Splunk Roles & Users
https://docs.splunk.com/Documentation/SplunkCloud/latest/Security/Rolesandcapabilities
Splunk roles and the capabilities they provide are additive.
Roles contain a set of capabilities a member user can perform. 
      A user can belong to one or more roles. By default the user role in Splunk, allows very permissive permission. 
Roles may be assigned to most of the knowledge objects in splunk.
However when a knowledge object does not have an owner, splunk cloud will override with user=nobody
As such if all knowledge objects do not have an explicit owner set, the role assigned will be associated with nobody, and as a system user/role, the capabilities granted cannot be overridden.

