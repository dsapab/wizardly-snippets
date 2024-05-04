# Wizardly Snippets - AWS CLI

## Index
- [Check Service Availability](#check-service-vailability)

### Check Service Availability

Replacing the placeholder ```YOUR_SERVICE_NAME_HERE``` with the name of an AWS service, you can verify in which AWS regions it is available.

```
curl 'https://api.regional-table.region-services.aws.a2z.com/index.json' | jq -c '.prices[].attributes | select (."aws:serviceName" | contains("YOUR_SERVICE_NAME_HERE")) | ."aws:region"'
```
