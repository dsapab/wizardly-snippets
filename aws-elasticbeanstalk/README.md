# Wizardly Snippets - AWS Elastic Beanstalk

## Remove option settings

aws --region=us-west-1 elasticbeanstalk update-environment --environment-name <the-environment-name> --options-to-remove Namespace=aws:autoscaling:launchconfiguration,OptionName=ImageId


aws --region=eu-east-2 elasticbeanstalk update-environment --environment-name your-env-name --options-to-remove Namespace=aws:elasticbeanstalk:environment:process:default,OptionName=MatcherHTTPCode Namespace=aws:elasticbeanstalk:environment:process:default,OptionName=HealthCheckPath

## AL2 ##

{
  "GeneralConfig": {
    "AppUser": "webapp",
    "AppDeployDir": "/var/app/current/",
    "AppStagingDir": "/var/app/staging/",
    "ProxyServer": "nginx",
    "DefaultInstancePort": "80"
  },
  "PlatformSpecificConfig": {
    "PhpVersion": "7.4"
  }
}

/opt/elasticbeanstalk/bin/get-config platformconfig -k AppStagingDir



## Get environment variables AL1
/opt/elasticbeanstalk/bin/get-config environment -k hola

## Get directories
EB_SCRIPT_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k script_dir)
EB_APP_STAGING_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k app_staging_dir)
EB_CONFIG_APP_CURRENT=$(/opt/elasticbeanstalk/bin/get-config container -k app_deploy_dir)
EB_CONFIG_APP_LOGS=$(/opt/elasticbeanstalk/bin/get-config container -k app_log_dir)
EB_APP_USER=$(/opt/elasticbeanstalk/bin/get-config container -k app_user)
EB_SUPPORT_DIR=$(/opt/elasticbeanstalk/bin/get-config container -k support_dir)
EB_CONFIG_APP_PIDS=$(/opt/elasticbeanstalk/bin/get-config container -k app_pid_dir)
