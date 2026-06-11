terraform {
  source = "git::https://github.com/rodentskiedev/terraform-modules.git//aws_sso/aws_users?ref=v0.0.2"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  environment = get_env("TG_VAR_ENVIRONMENT")

  tags_vars = read_terragrunt_config(find_in_parent_folders("tags.hcl"))

  tags = local.tags_vars.locals[local.environment]
}

dependency "sso" {
  config_path = find_in_parent_folders("data/sso")

  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    instance_arn      = "i-123456"
    identity_store_id = "isd-123456"
  }
}

inputs = {
  identity_store_id = dependency.sso.outputs.identity_store_id
  users = {
    joe-bell = {
      display_name = "Joe Bell"
      user_name    = "joe.bell"
      given_name   = "Joe"
      family_name  = "Bell"
      email        = "rodentskie@gmail.com"
    }
    rodney-lingganay = {
      display_name = "Rodney Lingganay"
      user_name    = "rodney.lingganay"
      given_name   = "Rodney"
      family_name  = "Lingganay"
      email        = "rodney.lingganay@gmail.com"
    }
  }
}