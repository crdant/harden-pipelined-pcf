#!/usr/bin/env bash

set -eu

create_extension() {
  local extension_name=${1}
  local extension_properties=${2}

  om-linux \
    --target "$opsman_target" \
    --username "$opsman_user" \
    --password "$opsman_password" \
    --skip-ssl-validation \
    create-vm-extension \
    --name "${extension_name}" \
    --cloud-properties "${extension_properties}"
}

add_extension() {
  local product="${1}"
  local job="${2}"
  local extension_name="${3}"

  product_guid=$(
    om-linux \
      --target "$opsman_target" \
      --username "$opsman_user" \
      --password "$opsman_password" \
      --skip-ssl-validation \
      curl \
      --path /api/v0/staged/products \
      --silent |
      jq --raw-output ".[] | select ( .type == \"${product}\" ) | .guid"
  )

  job_guid=$(
    om-linux \
      --target "$opsman_target" \
      --username "$opsman_user" \
      --password "$opsman_password" \
      --skip-ssl-validation \
      curl \
      --path /api/v0/staged/products/${product_guid}/jobs \
      --silent |
      jq --raw-output ".jobs[] | select ( .name == \"${job}\" ) | .guid"
  )

  resources=$(
    om-linux \
      --target "$opsman_target" \
      --username "$opsman_user" \
      --password "$opsman_password" \
      --skip-ssl-validation \
      curl \
      --path /api/v0/staged/products/${product_guid}/jobs/${job_guid}/resource_config \
      --silent |
      jq ".additional_vm_extensions = [ \"${extension_name}\" ]"
  )

  echo "Creating extentions on ${product} (guid: ${product_guid}), jobs ${job} (guid: ${job_guid})..."
  om-linux \
    --target "$opsman_target" \
    --username "$opsman_user" \
    --password "$opsman_password" \
    --skip-ssl-validation \
    curl \
    --path /api/v0/staged/products/${product_guid}/jobs/${job_guid}/resource_config \
    --request PUT \
    --data "${resources}" \
    --silent

}

get_terraform_output() {
  output_name=${1}
  terraform output --state terraform-state/terraform.tfstate "${output_name}"
}

apply_security_group() {
  product="${1}"
  job=${2}
  security_group_id="${3}"

  vm_extension=$(
    jq -n \
      --arg name "${product}_${job}_sg" \
      --arg security_group_id ${security_group_id} \
      '{
        "name": $name,
        "cloud_properties": {
          "security_groups": [
            $security_group_id
          ]
        }
      }'
  )
  create_extension "${product}_${job}_sg" "${vm_extension}"
  add_extension "${product}" "${job}" "${product}_${job}_sg"
}

main () {
  capi_security_group="$(get_terraform_output "cloud_controller_security_group_id")"
  apply_security_group "cf" "cloud_controller" "${capi_security_group}"
}

main
