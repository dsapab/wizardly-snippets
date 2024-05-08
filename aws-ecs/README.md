# AWS ECS

# Index
- [Get latest AMI ECS id](#get-latest-ami-ecs-id)
- [Get available ECS AMI ids](#get-available-ecs-ami-ids)
- [Get available AMI ECS details](#get-latest-ami-ecs-details)

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
