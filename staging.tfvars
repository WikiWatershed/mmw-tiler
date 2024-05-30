##### PROJECT VARIABLES ####
# The following variables are global to the FilmDrop infrastructure stack
environment            = "staging"
project_name           = "mmw"
domain_zone            = "Z2N98U70LSHZAA"
s3_access_log_bucket   = ""
s3_logs_archive_bucket = ""

##### INFRASTRUCTURE FLAGS ####
# To disable each flag: set to 'false'; to enable: set to 'true'
deploy_vpc                               = false
deploy_vpc_search                        = false
deploy_log_archive                       = true
deploy_alarms                            = false
deploy_stac_server_opensearch_serverless = false
deploy_stac_server                       = false
deploy_analytics                         = false
deploy_titiler                           = true
deploy_console_ui                        = true
deploy_cirrus_dashboard                  = false
deploy_local_stac_server_artifacts       = false
deploy_sample_data_bucket                = false

##### NETWORKING VARIABLES ####
# If left blank, the infrastructure will try to query the values from the control tower vpc
vpc_id            = ""
vpc_cidr          = ""
security_group_id = ""
public_subnets_az_to_id_map = {
}

private_subnets_az_to_id_map = {
}

##### ALARM VARIABLES ####
sns_topics_map                 = {}
cloudwatch_warning_alarms_map  = {}
cloudwatch_critical_alarms_map = {}
sns_warning_subscriptions_map  = {}
sns_critical_subscriptions_map = {}

##### APPLICATION VARIABLES ####

titiler_inputs = {
  app_name                        = "titiler"
  domain_alias                    = "tiler.staging.modelmywatershed.org"
  deploy_cloudfront               = true
  mosaic_titiler_release_tag      = "v0.14.0-1.0.5"
  stac_server_and_titiler_s3_arns = []
  mosaic_titiler_waf_allowed_url  = "https://api.impactobservatory.com/stac-aws/"
  mosaic_titiler_host_header      = "tiler.staging.modelmywatershed.org"
  mosaic_titiler_host_header      = "tiler.staging.modelmywatershed.org"
  mosaic_tile_timeout             = 300
  web_acl_id                      = ""
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
  app_name            = "console"
  filmdrop_ui_release = "v5.5.0"
  deploy_cloudfront   = true
  domain_alias        = "console.staging.modelmywatershed.org"
  custom_error_response = [
    {
      error_caching_min_ttl = "10"
      error_code            = "404"
      response_code         = "200"
      response_page_path    = "/"
    }
  ]
  filmdrop_ui_config_file = "./console-ui/config.staging.json"
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
