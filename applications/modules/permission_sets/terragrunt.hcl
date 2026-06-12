terraform {
  source = "git::https://github.com/rodentskiedev/terraform-modules.git//aws_sso/aws_permission_sets?ref=v0.0.5"
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
  instance_arn = dependency.sso.outputs.instance_arn
  tags         = local.tags
  permission_sets = {
    admin = {
      name        = "AdministratorAccess"
      description = "Full administrative access"
      managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
    }
    power-user = {
      name        = "PowerUserAccess"
      description = "Power user access excluding IAM"
      managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess",
      ]
    }
    read-only = {
      name             = "ReadOnlyAccess"
      description      = "Read-only access to all services"
      session_duration = "PT2H"
      managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
      ]
    }
    billing = {
      name        = "BillingAccess"
      description = "Access to billing and cost management"
      managed_policies = [
        "arn:aws:iam::aws:policy/job-function/Billing",
      ]
    }
  }
}