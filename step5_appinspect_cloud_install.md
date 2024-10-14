

## Final install 

# requies both tokens 


```sh
curl -X POST 'https://staging.admin.splunk.com/clap-nutella-es/adminconfig/v2/apps/victoria' 
--header 'X-Splunk-Authorization: eyJraWQiOiJhdTVGakVpOH..uWl7jTnmV9iBrAl2DE4vnPE1CQJjsYFvXPwkdV7g' 
--header 'Authorization: Bearer eyJraWQiOiJzcGx1bmsuc2..jgr0D91ha-bbOzKQw' 
--header 'ACS-Legal-Ack: Y' --data-binary '@/Users/mcronkrite/Downloads/DA-tu-security-content-20-stage.spl'
```
