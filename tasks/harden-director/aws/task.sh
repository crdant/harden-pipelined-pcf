#!/bin/bash

set -eu

read -r -d '' iaas_configuration <<EOF
{
  "encrypted": true
}
EOF


om-linux \
  --target https://${OPSMAN_DOMAIN_OR_IP_ADDRESS} \
  --skip-ssl-validation \
  --username "$OPSMAN_USER" \
  --password "$OPSMAN_PASSWORD" \
  configure-director \
  --iaas-configuration "$iaas_configuration" \
