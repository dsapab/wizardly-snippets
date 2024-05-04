# Wizardly Snippets - AWS CLI

# Index
- [Check Service Availability](#check-service-vailability)
- [Get latest AMI ECS id](#get-latest-ami-ecs-id)
- [Get available ECS AMI ids](#get-available-ecs-ami-ids)
- [Get available AMI ECS details](#get-available-ami-ecs-details)
- [Delete buckets recursively](#delete-buckets-recursively)


## Check Service Availability

Replacing the placeholder ```YOUR_SERVICE_NAME_HERE``` with the name of an AWS service, you can verify in which AWS regions it is available.
```
$> curl 'https://api.regional-table.region-services.aws.a2z.com/index.json' | jq -c '.prices[].attributes | select (."aws:serviceName" | contains("YOUR_SERVICE_NAME_HERE")) | ."aws:region"'
```

## Get latest AMI ECS id
```
$> aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-ecs-hvm-?.?.????????-x86_64-ebs' 'Name=state,Values=available' --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId' --output text
```

## Get available ECS AMI ids
```
$> aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-ecs-hvm-?.?.????????-x86_64-ebs' 'Name=state,Values=available' --query 'reverse(sort_by(Images, &CreationDate))[:].[CreationDate,ImageId,ImageLocation,Description]' --output table
```

## Get latest AMI ECS details
```
$> aws --region=eu-west-1 ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-ecs-hvm-?.?.????????-x86_64-ebs' 'Name=state,Values=available' --query 'reverse(sort_by(Images, &CreationDate))[:1]' --output table
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
