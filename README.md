# learn-nomad

## Setup

Ensure you have nomad and vault installed locally and available on the `PATH`. For example using brew:
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/vault
brew install hashicorp/tap/nomad
```

## Start and configure the nomad agent as a client + server

**start nomad dev server in a terminal**
```bash
sudo nomad agent -dev -bind 0.0.0.0 -log-level INFO -config agent-conf.hcl
```

**Bootstrap ACL and create policies**
```
nomad acl boostrap

# a secret ID is returned, set this as NOMAD_TOKEN in the env e.g.
export NOMAD_TOKEN=<secret id>

# create the developer poiicy
nomad acl policy apply developer developer.policy.hcl
```

**Create a developer token and run a job**
```bash
nomad acl token create -policy=developer -global

# a secret ID is returned, set this as NOMAD_TOKEN in the env but first
# save the existing token for later admin use, or for use with the vault
# instructions below
NOMAD_TOKEN_BOOTSTRAP=$NOMAD_TOKEN
NOMAD_TOKEN=<the new secret id>

# check you can run a job
nomad run job echo.nomad

# check the status and allocations
nomad job status docs
nomad alloc status <alloc>

# from the above alloc status(es) find the http port and it with curl e.g. from nomad alloc status <alloc id>
# Allocation Addresses
# Label   Dynamic  Address
# *http   yes      127.0.0.1:28060
# *dummy  yes      127.0.0.1:26139
curl localhost:28060

# expected output is "hello world"
```

## Provisioning tickets with vault

**Start vault dev server in a terminal**
```bash
vault server -dev
```

**Configure nomad secrets and vault policies**

Note: the first vault command will automatically store the root token in `~/.vault-token`.
```bash
vault secrets enable nomad
vault write nomad/config/access \
  token=$NOMAD_TOKEN_BOOTSTRAP \
  address=http://127.0.0.1:4646

vault policy write nomad-developer vault-nomad-developer-policy.hcl
vault policy write nomad-admin vault-nomad-admin-policy.hcl
```

**Create a nomad role in vault as a vault nomad-admin**
```bash
# create a vault token with the nomad-admin policy and use this to provision a nomad role
vault token create -display-name=nomad-admin -policy=nomad-admin

# set the secret id as VAULT_TOKEN e.g.
export VAULT_TOKEN=<secret id>

vault write nomad/role/developer policies=developer
```

**Create a vault token for retrieving the credentials as a vault nomad-developer and retrieve a nomad token**
```bash
# create a vault token with the nomad-admin policy and use this to provision a nomad role
vault token create -display-name=nomad-developer-1 -policy=nomad-developer

# set the secret id as VAULT_TOKEN e.g.
export VAULT_TOKEN=<secret id>

vault read nomad/creds/developer

# set the secret id as NOMAD_TOKEN e.g.
export NOMAD_TOKEN=<secret id>

# check expected nomad commands work e.g.
nomad job status

# check expected nomad command don't work e.g.
nomad system gc
```
