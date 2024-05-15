<!-- omit from toc -->
# Model My Watershed Tiler Deployment

- [Setup](#setup)
- [Deploying](#deploying)
  - [Via GitHub Actions](#via-github-actions)
  - [Manual Deploy](#manual-deploy)
- [Destroy](#destroy)
  - [Via GitHub Actions](#via-github-actions-1)
  - [Manual Deploy](#manual-deploy-1)

This repository deploys [TiTiler](https://github.com/developmentseed/titiler)
(as the fork [titiler-mosaicjson](https://github.com/Element84/titiler-mosaicjson))
and [FilmDrop UI](https://github.com/Element84/filmdrop-ui) via the
[FilmDrop Infrastructure Terraform Modules](https://github.com/Element84/filmdrop-aws-tf-modules).

## Setup

1. Create the bootstrap resources as outlined in [this readme](boostrap/README.md).
2. Create an Environment (e.g., `staging`) with Environment Secrets:

- `AWS_REGION`: region to deploy into
- `AWS_ROLE` : the ARN of the AWS Role to use for deploy
- `TF_STATE_BUCKET`: the bucket use for storing Terraform state
- `TF_STATE_LOCK_TABLE`: the DynamoDB table to use for Terraform locks
- `SLACK_BOT_TOKEN`: Slack Bot Token
- `SLACK_CHANNEL_ID`: ID of Slack channel to post deploy status notifications

## Deploying

### Via GitHub Actions

TBD.

### Manual Deploy

By default FilmDrop Terraform deployment is configured to use S3 and DynamoDB as
its state file store. The GitHub Actions build will create this file as
`staging.s3.backend.tf`. When running locally, you can create this file:

```text
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = REPLACE_ME # REPLACE with the bootstrapped bucket name
    dynamodb_table = "filmdrop-terraform-state-locks"
    key            = "mmw-username-test.tfstate" # REPLACE username with our own
    region         = "us-west-2"
  }
}
```

to use S3 as the backend. If this is excluded, the default local backend will be used.

Download the filmdrop-aws-tf-modules source:

```shell
export FILMDROP_TERRAFORM_RELEASE=v2.22.0
wget -qO- https://github.com/Element84/filmdrop-aws-tf-modules/archive/refs/tags/${FILMDROP_TERRAFORM_RELEASE}.tar.gz | tar xvz
mkdir -p modules
mkdir -p profiles
cp filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/filmdrop.tf .
cp filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/providers.tf .
cp filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/inputs.tf .
cp -r filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/modules .
cp -r filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/profiles .
rm -rf filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}
```

Then run the Terraform commands

```shell
terraform init
terraform validate
terraform plan -var-file=staging.tfvars -out tfplan
terraform apply -input=false tfplan
```

If you prefer to use a local state file you can delete the backend.tf file (or
simply comment out the S3 configuration) and omit the `-backend-config` option
in your `terraform init` command. Without a backend.tf file Terraform will
default to a local store for its state file.

## Destroy

### Via GitHub Actions

TODO

### Manual Deploy

Run `terraform destroy -var-file=staging.tfvars -input=false`
