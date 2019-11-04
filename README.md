# Branch Protector 3000
The Branch Protector 3000 assists organization with new repositories to ensure they have best practices for branch protections enabled. 

### Setup
1.
1. `make dist` will bundle and install application dependencies for deployment
2. To bring up the infrastructure you will need to ensure your [AWS credentials have been configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) and your GitHub token has permissions for `admin:org_hook, public_repo` and that the token has been exported in your environment `export GITHUB_TOKEN=************`.
3. `cd infra && terraform init && terraform plan` will show you the infrastructure that is to be created and `terraform apply` will 

### Development Guide
If you have deployed to a dev environment the Lambda editor and/or AWS Cloud9 work well for in the cloud development and testing of the application. Otherwise you need to ensure your AWS user has the proper permissions to make the necessary API calls, namely KMS and parameter store. You will also need the following env vars exported into your environment.

```
variables = {
    REGION      = "us-west-2",
    NOTIFY_USER = "banthaherder",
    SSM_PREFIX  = "BRANCH_PROTECTOR"
}
```

### Next Steps/Improvements
* Make the infrastructure components into reuseable modules to enable simple swapout of hard coded organization values (i.e. name, domain, user, etc)
* Create VPC infrastructure from scratch or tag existing. Presently crucial VPC and SG ids are being passed in due default infra in this AWS account.
* Handle repos created without a master branch (i.e. create a master branch)
* Improve the developer experience by extracting core application functionality from requirements of the Lambda
* Architecture diagram