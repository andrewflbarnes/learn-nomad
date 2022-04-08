path "nomad/creds" {
  capabilities = ["read", "create", "update", "delete", "list"]
}

path "nomad/role" {
  capabilities = ["read", "list"]
}
