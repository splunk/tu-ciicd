## Step 3 - Create inital app packages locally 


> Some great referense about Recommended testing for cloud approaches (include ci/cd comments)
- https://dev.splunk.com/enterprise/docs/developapps/testvalidate
- https://dev.splunk.com/enterprise/docs/releaseapps
- https://dev.splunk.com/enterprise/docs/releaseapps/manageprivatecloud

- From the command line, go to the `$SPLUNK_HOME/etc/apps`
- Create our first initializing AD-Hoc app here
- `$SPLUNK_HOME/etc/apps/<appname>`
- `TA-tu_amer_content`

#### Create our first initializing ES dev/stage/prod apps here.

> $SPLUNK_HOME/etc/apps/<appname>
- DA-ESS-security-content-10-dev
- DA-ESS-security-content-20-stage
- DA-ESS-security-content-30-prod


########
```
##  It is CRITICAL to increment the app version in app.conf with a VALID version number 
##  semantic versioning only
##     MUST have no special characters except + and -
##     "(?<good>.*\d+\.\d+\.\d+(-[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*)?(\+[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*)?$)"
##     MUST follow pattern of digits dot digits dot digits 
##      followed only by + or - then any letter or digits 
```
########

#### Step 1.3 Validate and package the first app 

> https://dev.splunk.com/enterprise/tutorials/module_validate/packageapp#Validate-and-package-the-app
> in that link *step 2*

##### ensure that permissions are set to splunk user 
> `chmod -R u+rw,g-rwx,o-rwx splunkuser`

> `slim generate-manifest <appname> -o <appname>/app.manifest`

##### keep running manifest until everything is good, (should be)
> `slim validate <appname>`

##### ensure that permissions are set to splunk user again after modifications
> `chmod -R u+rw,g-rwx,o-rwx splunkuser`

> https://dev.splunk.com/enterprise/docs/releaseapps/packageapps
##### remove any extra files from package
> `COPYFILE_DISABLE=1 tar --format ustar -cvzf <appname>.tar.gz <appname_directory>`

##### run appinspect CLI locally to see if we are good for cloud as a private app
> https://dev.splunk.com/enterprise/docs/releaseapps/cloudvetting
> https://dev.splunk.com/enterprise/docs/developapps/testvalidate/appinspect/useappinspectclitool

> `splunk-appinspect list checks --included-tags future`
> `splunk-appinspect inspect <appname>.tgz --included-tags cloud --included-tags self-service --excluded-tags splunk-appinspect`
