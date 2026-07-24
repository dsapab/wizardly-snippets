# AWS CloudFormation

Links to CloudFormation templates and solutions that live in their own repos, kept here so they are browsable in one place. Everything below is in [dsapab/aws-cloudformation-samples](https://github.com/dsapab/aws-cloudformation-samples).

# Index
- [EC2 Spot bastion](#ec2-spot-bastion)
- [EC2 GPU Docker](#ec2-gpu-docker)
- [Beanstalk CI/CD](#beanstalk-cicd)
- [ECS Fargate + ALB](#ecs-fargate--alb)
- [ECS Fargate service dependency](#ecs-fargate-service-dependency)
- [VPC public/private setup](#vpc-publicprivate-setup)


## EC2 Spot bastion
Bastion hosts on EC2 Spot instances, each in its own size-1 Auto Scaling group so a reclaimed Spot instance is replaced automatically. OS-agnostic (Amazon Linux 2023, Ubuntu, RHEL), with optional Elastic IP and persistent data volume, and SSM Session Manager access.

[→ ec2-spot-bastion](https://github.com/dsapab/aws-cloudformation-samples/tree/master/ec2-spot-bastion)

## EC2 GPU Docker
GPU-backed EC2 for running Docker containers, with NVIDIA drivers. Includes both a single-instance template and a Spot fleet template.

[→ ec2-gpu-docker](https://github.com/dsapab/aws-cloudformation-samples/tree/master/ec2-gpu-docker)

## Beanstalk CI/CD
CI/CD pipeline that builds a Docker app and deploys it to Elastic Beanstalk, with a `buildspec.yaml` and sample app included.

[→ beanstalk-cicd](https://github.com/dsapab/aws-cloudformation-samples/tree/master/beanstalk-cicd)

## ECS Fargate + ALB
An ECS Fargate service fronted by an Application Load Balancer.

[→ ecs-fargate-alb](https://github.com/dsapab/aws-cloudformation-samples/tree/master/ecs-fargate-alb)

## ECS Fargate service dependency
ECS Fargate services with a dependency ordering between them.

[→ ecs-fargate-service-dependency](https://github.com/dsapab/aws-cloudformation-samples/tree/master/ecs-fargate-service-dependency)

## VPC public/private setup
A VPC with public and private subnets.

[→ vpc-public-private-setup](https://github.com/dsapab/aws-cloudformation-samples/tree/master/vpc-public-private-setup)
