<!-- omit from toc -->
# Model My Watershed Tiler Deployment

- [Development](#development)
- [Pre-deploy setup](#pre-deploy-setup)
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

## Development

Install pre-commit hooks:

```bash
pre-commit install
```

And run them with:

```bash
pre-commit run --all-files
```

Due to an issue with VSCode, the wrong JSON Schema is selected for the file
`.github/workflows/deploy.yaml`. To prevent this, add the following to your
`.vscode/settings.json`:

```json
{
    "yaml.schemas": {
        "https://json.schemastore.org/github-workflow.json": [".github/workflows/*.{yml,yaml}"]
    }
}
```

## Pre-deploy setup

1. In the AWS Accounts to be deployed into, create the bootstrap resources as
   outlined in <bootstrap/README.md>.

## Deploying

### Via GitHub Actions

Create a GitHub Environment (e.g., `staging`) with these Environment Secrets:

| Variable              | Description                                             | Example                                                                               |
| --------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| `AWS_REGION`          | region to deploy into                                   | `us-west-2`                                                                           |
| `AWS_ROLE`            | the ARN of the AWS Role to use for deploy               | `arn:aws:iam::0123456789:role/appFilmDropDeployRoleBootstrap-DeployRole-Wfx5HwlneOVM` |
| `TF_STATE_BUCKET`     | the bucket use for storing Terraform state              | `filmdrop-{project_name}-{region}-terraform-state-{random_string}`                    |
| `TF_STATE_LOCK_TABLE` | the DynamoDB table to use for Terraform locks           | `filmdrop-terraform-state-locks`                                                      |
| `SLACK_CHANNEL_ID`    | ID of Slack channel to post deploy status notifications | `D26F29X7OB3`                                                                         |
| `SLACK_BOT_TOKEN`     | Slack Bot Token                                         | alphanumeric string                                                                   |

The following GitHub Actions will run under the following situations:

- The validation workflow will run upon any push to any branch. This runs
  some tests on the validity of the Terraform configuration.
- The staging workflow will run upon push to `main` or any tag starting with `v`.
- The prod workflow will run upon push to any tag starting with `v`.

The staging and prod workflows require manual approval to access their respective
GitHub Environments.

### Manual Deploy

By default, Terraform will use a local store for state. If you want to configure
this to use S3 and DynamoDB instead, in the same way the GitHub Actions build does,
create a file to define the backend named `config.s3.backend.tf` with contents like:

```text
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = REPLACE_ME # with the bootstrapped bucket name
    dynamodb_table = "filmdrop-terraform-state-locks"
    key            = "mmw-{username}-test.tfstate" # replace with username
    region         = "us-west-2"
  }
}
```

The `bucket` name will be the value to be set for `TF_STATE_BUCKET`, e.g.,
`filmdrop-{project_name}-{region}-terraform-state-{random_string}`.

Download the filmdrop-aws-tf-modules source:

```shell
./scripts/retrieve_tf_modules.sh v2.24.0
```

Re-run this anytime you with to uptake a new `filmdrop-aws-tf-modules` release,
in addition to updating the env var in `.github/workflows/ci.yaml`.

Run the Terraform commands to initialize, validate, plan, and apply the
configuration:

```shell
terraform init
terraform validate
terraform plan -var-file=staging.tfvars -out tfplan
terraform apply -input=false tfplan
```

If you prefer to use a local state file, can delete the `config.s3.backend.tf`
file and run `terraform init` again without it.

## Destroy

### Via GitHub Actions

Not currently supported.

### Manual Deploy

Run `terraform destroy -var-file=staging.tfvars -input=false`
