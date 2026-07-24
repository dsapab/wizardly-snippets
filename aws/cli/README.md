# AWS CLI

# Index
- [Check service availability](#check-service-availability)
- [Delete buckets recursively](#delete-buckets-recursively)


## Check service availability

Replacing the placeholder ```YOUR_SERVICE_NAME_HERE``` with the name of an AWS service, you can verify in which AWS regions it is available.
```
$> curl 'https://api.regional-table.region-services.aws.a2z.com/index.json' | jq -c '.prices[].attributes | select (."aws:serviceName" | contains("YOUR_SERVICE_NAME_HERE")) | ."aws:region"'
```

## Delete buckets recursively
```
$> aws s3api list-buckets \
   --query 'Buckets[?starts_with(Name, `test`) == `true`].[Name]' \
   --output text | xargs -I {} aws s3 rm s3://{} --recursive

$> aws s3api list-buckets \
   --query 'Buckets[?starts_with(Name, `test`) == `true`].[Name]' \
   --output text | xargs -I {} aws s3 rb s3://{} --force
```
