terraform {
  source = "git::https://github.com/rodentskiedev/terraform-modules.git//data/accounts?ref=v0.0.7"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {}