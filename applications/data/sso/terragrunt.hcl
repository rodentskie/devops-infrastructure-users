terraform {
  source = "git::https://github.com/rodentskiedev/terraform-modules.git//data/sso_instance?ref=v0.0.2"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {}