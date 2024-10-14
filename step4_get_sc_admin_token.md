## Step 4.1 Install App, first must pass AppInspect in Cloud

### REQUIREMENTS 
- a user account on splunk.com 
- a user account, WITH `sc_admin` role, on the  ADHOC cluster of the target stack 

##### 
```
# environment = staging.admin.splunk.com
# stackname_adhoc = clap-nutella-es
# acs = /adminconfig/v2
# user = macecron
# password = yourpassword
```
###### 

**Prep:**

- Get **Token** for ADHOC on Cloud Stack 
- user must be `sc_admin` in adhoc

> `curl -u <user>:<password> -X POST 'https://<environment>/<stackname_adhoc>/<acs>/tokens' --header 'Content-Type: application/json' --data-raw '{"user" : "<user>","for sc_admins" : "install app victoria", "expiresOn" : "+5d"}' `

Receive back token, for example: 
```json
{"user":"macecron","audience":"acs-test","id":"3ecf92ee19723c9907139f13f456898830cd69349a5884be02838d65064520e9",
 "token":"eyJraWQiOiJ...LDyNEUkw"
 ,"status":"enabled","expiresOn":"2025-01-19T22:06:07Z","notBefore":"2024-10-11T22:06:07Z"}
```

> ℹ️ copy this token value for the further Cloud stack commands 

> Get Token for api at Splunk.Com for AppInspect  (this would be the credential that you'd be using to login to Splunkbase.com or Splunk.com) 

```
#### 
# splunkcomuser = mcronkrite@splunk.com
#####
```

> `curl -u <splunkcomuser> --url "https://api.splunk.com/2.0/rest/login/splunk"`

# receive back token 
# for example 
# 


# copy this token for appinspect api commands
