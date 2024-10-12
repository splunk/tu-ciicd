# tu-ciicd 

Requirements
- Splunk Enterprise Dev/Test License
- Splunk Enterprise, full install standalone, linux
- Splunk Cloud Victoria version minimum 9.2.2304
- Splunk Cloud sc_admin account, with Export Apps role added

Splunk Cloud Victoria - Required Knowlege
- Does not allow you to target a specific environment for app install/update.
- All apps are installed to all stack search heads (Adhoc and ES)
- Enabled saved searches on install will run on all search heads (Adhoc and ES)
- App default content will be replicated to both (Adhoc and ES)
- Apps with any Knowledge Objects without explicit ownership will be a default role of nobody
- Local Content can only be Exported from private customer apps, and the search app.
- Local Content in Splunkbase/Splunk restricted apps requie a support case to retrieve files.
- Do not upload Lookup definition updates via App
- Lookup defintions cannot be modified after app install progamatically, Lookup Editor in GUI is current process
- Data Model definitions that override the Splunk_SA_CIM will not be setup to allow shared data model summaries.

Impact
- User and Content Management Goverance of the Splunk Cloud as a unified platform is critical
- Least privledged RBAC and explicit knowledge object ownership and permissions is a must for platform stability
