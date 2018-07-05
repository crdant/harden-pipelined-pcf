#!/bin/bash

set -eu

create_extension() {
  local extension_name=${1}
  local extension_properties=${2}

  om \
    --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
    --username "$OPS_MGR_USR" \
    --password "$OPS_MGR_PWD" \
    --skip-ssl-validation \
    create-vm-extension \
    --name "${extension_name}"
    --cloud-properties "${extension_properties}"
}

add_extension() {
  local product="${1}"
  local job="${2}"
  local extension_name="${3}"

  product_guid=$(
    om \
      --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
      --username "$OPS_MGR_USR" \
      --password "$OPS_MGR_PWD" \
      --skip-ssl-validation \
      curl \
      --path /api/v0/staged/products \
      --silent |
      jq --raw-output ".[] | select ( .type == \"${product}\" ) | .guid"
  )

  job_guid=$(
    om \
      --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
      --username "$OPS_MGR_USR" \
      --password "$OPS_MGR_PWD" \
      --skip-ssl-validation \
      curl \
      --path /api/v0/staged/products/${product_guid}/jobs \
      --silent |
      jq --raw-output ".jobs[] | select ( .name == \"${job}\" ) | .guid"
  )

  resources=$(
    om \
      --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
      --username "$OPS_MGR_USR" \
      --password "$OPS_MGR_PWD" \
      --skip-ssl-validation \
      curl \
      --path /api/v0/staged/products/${product_guid}/jobs/${job_guid}/resource_config \
      --silent |
      jq ".additional_vm_extensions = [ \"${extension_name}\" ]"
  )

  om \
    --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
    --username "$OPS_MGR_USR" \
    --password "$OPS_MGR_PWD" \
    --skip-ssl-validation \
    curl \
    --path /api/v0/staged/products/${product_guid}/jobs/${job_guid}/resource_config
    --request PUT \
    --data "${resources}"

}

get_security_group_id() {
  output_name=${1}
  terraform output "${output_name}"
}

apply_security_group() {
  product="${1}"
  job=${2}
  security_group_id="${3}"

  vm_extension=$(
    jq -n \
      --arg product ${product}
      --arg job ${job}
      --arg security_group_id ${security_group_id}
      '{
        "name": "$product_$job_sg",
        "cloud_properties": {
          "security_groups": [
            "$security_group_id"
          ]
        }
      }'
  )
  create_extension "${product}_${job}_sg" "${bosh_extension}"
  add_extension "${product}" "${job}" "${product}_${job}_sg"

}

main () {
  bosh_security_group="$(get_security_group_id "director_security_group")"
  apply_security_group "p-bosh" "director" "${bosh_security_group}"

  capi_security_group="$(get_security_group_id "cloud_controller_security_group")"
  apply_security_group "cf" "cloud_controller" "${capi_security_group}"
}

main
