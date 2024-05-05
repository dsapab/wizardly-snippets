# Docker

# Index
- [Basic docker workflow and pusht to AWS ECR](#basic-docker-workflow-and-push-to-AWS-ECR)


## Basic docker workflow and push to AWS ECR
1. Log in into ECR

Please replace the ```<AWS_REGION>``` and ```<AWS_URI>``` placeholders with the proper values. In successive commands, we will using ```123456789123.dkr.ecr.us-east-1.amazonaws.com/test-image``` as the URI sample.
```
aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_URI>
```
2. Build the docker image
```
docker build --tag 123456789123.dkr.ecr.us-east-1.amazonaws.com/test-image .
```
3. Push it to ECR
```
docker push 123456789123.dkr.ecr.us-east-1.amazonaws.com/test-image
```
4. Pull the image that has just been uploaded
```
docker pull 123456789123.dkr.ecr.us-east-1.amazonaws.com/test-image:latest
```
