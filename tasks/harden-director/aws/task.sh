#!/usr/bin/env bash

set -eu

set_encrypted_disks () {
  local iaas_configuration="$(
    jq -n \
      '{
          "encrypted": true
       }'
    )"

  om-linux \
    --target "$opsman_target" \
    --username "$opsman_user" \
    --password "$opsman_password" \
    --skip-ssl-validation \
    configure-director \
    --iaas-configuration "$iaas_configuration"
}

main () {
  set_encrypted_disks
}

main
