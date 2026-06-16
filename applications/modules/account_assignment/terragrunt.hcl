terraform {
  source = "git::https://github.com/rodentskiedev/terraform-modules.git//aws_sso/aws_account_assignment?ref=v0.0.7"
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

dependency "permissions" {
  config_path = find_in_parent_folders("modules/permission_sets")

  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    admin = {
      name               = "tmp"
      permission_set_arn = "arn:aws:sso:::abcd"
    },
    billing = {
      name               = "tmp"
      permission_set_arn = "arn:aws:sso:::abcd"
    },
    power-user = {
      name               = "tmp"
      permission_set_arn = "arn:aws:sso:::abcd"
    },
    read-only = {
      name               = "tmp"
      permission_set_arn = "arn:aws:sso:::abcd"
    }
  }
}

dependency "accounts" {
  config_path = find_in_parent_folders("data/account")

  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan"]
  mock_outputs = {
    klaro-dev = {
      arn = "arn:aws:organiztions::abcdef"
      id  = "1234567890"
    },
    system = {
      arn = "arn:aws:organiztions::abcdef"
      id  = "1234567890"
    },
    "rodentskie.dev" = {
      arn = "arn:aws:organiztions::abcdef"
      id  = "1234567890"
    }
  }
}

inputs = {
  instance_arn = dependency.sso.outputs.instance_arn
  assignments = {
    root = {
      account_id         = dependency.accounts.outputs.accounts["rodentskie.dev"].id
      group_id           = dependency.groups.outputs.groups["platform-admins"].group_id
      permission_set_arn = dependency.permissions.outputs.permission_sets["admin"].permission_set_arn
    }
    system = {
      account_id         = dependency.accounts.outputs.accounts["system"].id
      group_id           = dependency.groups.outputs.groups["platform-admins"].group_id
      permission_set_arn = dependency.permissions.outputs.permission_sets["admin"].permission_set_arn
    }
    klaro-admin = {
      account_id         = dependency.accounts.outputs.accounts["klaro-dev"].id
      group_id           = dependency.groups.outputs.groups["platform-admins"].group_id
      permission_set_arn = dependency.permissions.outputs.permission_sets["admin"].permission_set_arn
    }
    klaro-developer = {
      account_id         = dependency.accounts.outputs.accounts["klaro-dev"].id
      group_id           = dependency.groups.outputs.groups["developers"].group_id
      permission_set_arn = dependency.permissions.outputs.permission_sets["read-only"].permission_set_arn
    }
  }
}