##### PROJECT VARIABLES ####
# The following variables are global to the FilmDrop infrastructure stack
environment            = "prod"
project_name           = "mmw"
domain_zone            = "Z2IL9F9SQ608FV"
s3_access_log_bucket   = ""
s3_logs_archive_bucket = ""

##### INFRASTRUCTURE FLAGS ####
# To disable each flag: set to 'false'; to enable: set to 'true'
deploy_vpc                               = true
deploy_vpc_search                        = false
deploy_log_archive                       = true
deploy_cirrus                            = false
deploy_alarms                            = false
deploy_stac_server_opensearch_serverless = false
deploy_stac_server                       = false
deploy_analytics                         = false
deploy_titiler                           = true
deploy_console_ui                        = true
deploy_cirrus_dashboard                  = false
deploy_local_stac_server_artifacts       = false

##### NETWORKING VARIABLES ####
# If left blank, the infrastructure will try to query the values from the control tower vpc
vpc_id            = ""
vpc_cidr          = "10.26.0.0/18"
security_group_id = ""
public_subnets_az_to_id_map = {
  "us-west-2a" = "10.26.0.0/22"
  "us-west-2b" = "10.26.4.0/22"
  "us-west-2c" = "10.26.8.0/22"
}

private_subnets_az_to_id_map = {
  "us-west-2a" = "10.26.12.0/22"
  "us-west-2b" = "10.26.16.0/22"
  "us-west-2c" = "10.26.20.0/22"
}


##### ALARM VARIABLES ####
sns_topics_map                 = {}
cloudwatch_warning_alarms_map  = {}
cloudwatch_critical_alarms_map = {}
sns_warning_subscriptions_map  = {}
sns_critical_subscriptions_map = {}

##### APPLICATION VARIABLES ####

titiler_inputs = {
  app_name                       = "titiler"
  domain_alias                   = "tiler.modelmywatershed.org"
  deploy_cloudfront              = true
  version                        = "v0.14.0-1.0.5"
  authorized_s3_arns             = []
  mosaic_titiler_waf_allowed_url = "https://api.impactobservatory.com/stac-aws/"
  mosaic_titiler_host_header     = "tiler.modelmywatershed.org"
  mosaic_tile_timeout            = 900
  web_acl_id                     = ""
  auth_function = {
    cf_function_name             = ""
    cf_function_runtime          = "cloudfront-js-2.0"
    cf_function_code_path        = ""
    attach_cf_function           = false
    cf_function_event_type       = "viewer-request"
    create_cf_function           = false
    create_cf_basicauth_function = false
    cf_function_arn              = ""
  }
}

console_ui_inputs = {
  app_name          = "console"
  version           = "v5.5.0"
  deploy_cloudfront = true
  domain_alias      = "console.prod.modelmywatershed.org"
  custom_error_response = [
    {
      error_caching_min_ttl = "10"
      error_code            = "404"
      response_code         = "200"
      response_page_path    = "/"
    }
  ]
  filmdrop_ui_config_file = "./console-ui/config.prod.json"
  filmdrop_ui_logo_file   = "./console-ui/logo.png"
  filmdrop_ui_logo        = "bm9uZQo=" # Base64: 'none'
  auth_function = {
    cf_function_name             = ""
    cf_function_runtime          = "cloudfront-js-2.0"
    cf_function_code_path        = ""
    attach_cf_function           = false
    cf_function_event_type       = "viewer-request"
    create_cf_function           = false
    create_cf_basicauth_function = false
    cf_function_arn              = ""
  }
}
