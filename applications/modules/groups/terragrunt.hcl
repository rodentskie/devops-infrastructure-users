terraform {
  source = "git::https://github.com/rodentskiedev/terraform-modules.git//aws_sso/aws_groups?ref=v0.0.2"
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
  groups = {
    platform-admins = {
      display_name = "Platform Admins"
      description  = "Full access to platform accounts"
    }
    developers = {
      display_name = "Developers"
      description  = "Read/write access to workload accounts"
    }
    read-only = {
      display_name = "Read Only"
    }
  }
}