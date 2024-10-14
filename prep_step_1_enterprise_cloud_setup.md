## Step 1
### Install and Setup Splunk Enterprise, Standalone Local, with Dev/Test License

- Whether you plan to build apps for Splunk Cloud Platform or Splunk Enterprise
- you need a local installation of Splunk Enterprise for your development environment. 
- With Splunk Enterprise you have access to the file system, but you don't have direct access to these files when using Splunk Cloud Platform.

> You must have an Enterprise or Dev/Test License, because we need to use the SHC Deployer capability, appinspect, and package-toolkit

> Install Splunk Enterprise localy as usual

## Step 1.1  

> https://dev.splunk.com/enterprise/tutorials/module_validate/packageapp/

- Download the Splunk Packaging Toolkit from Downloads.
- Install the .tar.gz file in the same development environment as your app files, which is on the same computer as Splunk Enterprise .... or pip

################################
## Step 2

> Create an `sc_admin` user on ALL search head groups AdHoc and ES and (ITSI) if needed.
- Keep the users with `sc_admin` as low as possible to ensure platform stability

> Create **Content Management Roles** for each Search Head group, eg. IT-content-mgr and ES-content-mgr 
- ON ALL Search Head Groups, all these roles will be defined
- This configuration will help ensure that each of these content roles will have permissions removed in the Search Head Groups that they should not write to.

> Create Content Users for each Search Head group, eg. IT-content-owner and ES-content-owner
- ON ALL Search Head Groups, all these content owners will be defined.
- This configuration will help ensure that that there is always an availalable owner to assign, so that the Splunk system user like NOBODY, does not inadvertantly get access to KOs'



#### Create content role on Adhoc first. 
- Log in to GUI of Adhoc as an sc_admin
- Add `export_apps` role to your `sc_admin` user

#### Create a role called [es_security_content_manager]
On AD-HOC,and ITSI this role has NO CAPABILITIES
NO search
NO scheduled search
NO access to all indexes
NO capabilities
#### Set the es_security_content_manager role on Ad-Hoc and ITSI to limitied Jobs, search windows, and diskspace
Role search job limit, 5 standard, 5 real-time
User search job limit, 3 standard, 1 real-time
Role search time window max 60, earliest 600
Disk space limit 10mb
Set the default app to - SEARCH app

- Reload Auth Configuration

Return to role `es_security_content_manager` observe 5 NATIVE capabilities have returned automatically back, remove them again, except edit_own_objects, and list_all_objects

- Create a user called es_security_content_owner
set the default app to **Search and Reporting**
ensure there are NO other roles, including user inherited.
assign only to the role `es_security_content_manager`


#### now repeat for `bu_adhoc_content_manager` on Adhoc still 


As an sc_admin on the GUI on ES SH 
- Add `export_apps` role to your sc_admin user

- Create a role called es_security_content_manager
inherited the roles ess_admin, and ess_analyst, export_apps, ess_user
add `_audit` index, `_config_tracker` index, as included, not default

- change the roles default app to **SplunkEnterpriseSecuritySuite**

- Create a user called `es_security_content_owner`
ensure there are NO other roles, including user inherited.
assign only to the role es_security_content_manager
set default app to SplunkEnterpriseSecurity

########
- Create a user called `es_gui_demo_developer_user`
this is for demonstration purposes, represents your users’ own accounts
assign only to the role es_security_content_manager
set default app to SplunkEnterpriseSecurity

##########
- log out of both adhoc an es 
- validate that the user can
------- login 
-------- can't log in to other
--- can create content , like a saved search.
--- validate that that saved search does not run on the other search head , and vice versa
