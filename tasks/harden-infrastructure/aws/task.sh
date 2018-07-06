#!/usr/bin/env bash

set -eu

terraform_plan=${work_dir}/terraform.tfplan

get_ips() {
  cloudfront_ips=$(curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | jq --arg region "${region}" '[ .prefixes[] | select(.service=="CLOUDFRONT" and .region==$region) | .ip_prefix  ]')
  ec2_ips=$(curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | jq --arg region "${region}" '[ .prefixes[] | select(.service=="EC2" and .region==$region) |  .ip_prefix  ]')
  github_ips=$(curl -s https://api.github.com/meta | jq '.git')
}

init () {
  echo "Initializing terraform..."
  terraform init --input=false "${template_dir}"
}

plan () {
  echo "Planning terraform execution..."
  terraform plan \
    --state ${state_dir}/terraform.tfstate \
    --var "prefix=${prefix}" \
    --var "access_key_id=${access_key_id}" \
    --var "secret_access_key=${secret_access_key}" \
    --var "region=${region}" \
    --var "github_ips=${github_ips}" \
    --var "ec2_ips=${ec2_ips}" \
    --var "cloudfront_ips=${cloudfront_ips}" \
    --out "${terraform_plan}" \
    ${template_dir}
}

apply () {
  echo "Executing terraform plan..."
  terraform apply \
    --state-out ${output_dir}/terraform.tfstate \
    ${terraform_plan}
}

harden () {
  init
  plan
  apply
}

main () {
  get_ips
  harden
}

main $@
