terraform {
  source = "git::https://github.com/rodentskiedev/terraform-modules.git//aws_sso/aws_group_membership?ref=v0.0.3"
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

dependency "groups" {
  config_path = find_in_parent_folders("modules/groups")

  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    developers = {
      display_name = "tmp",
      group_id     = "abc-def"
    }
    platform-admins = {
      display_name = "tmp",
      group_id     = "abc-def"
    }
    read-only = {
      display_name = "tmp",
      group_id     = "abc-def"
    }
  }
}

dependency "users" {
  config_path = find_in_parent_folders("modules/users")

  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    joe-bell = {
      user_id   = "abcd-efgh"
      user_name = "tmp"
    },
    rodney-lingganay = {
      user_id   = "abcd-efgh"
      user_name = "tmp"
    }
  }
}

inputs = {
  identity_store_id = dependency.sso.outputs.identity_store_id
  memberships = {
    admins = {
      group_id = dependency.groups.outputs.groups["platform-admins"].group_id
      users = [
        dependency.users.outputs.users["rodney-lingganay"].user_id,
      ]
    }
    developers = {
      group_id = dependency.groups.outputs.groups["developers"].group_id
      users = [
        dependency.users.outputs.users["joe-bell"].user_id,
      ]
    }
    read-only = {
      group_id = dependency.groups.outputs.groups["read-only"].group_id
      users = [
        dependency.users.outputs.users["joe-bell"].user_id,
      ]
    }
  }
}