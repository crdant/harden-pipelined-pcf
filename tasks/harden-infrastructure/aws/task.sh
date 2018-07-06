#!/bin/bash

set -eu

copy_templates () {
  cp -R pcf-pipelines-base/* pcf-pipelines
  cp harden-pipelined-pcf/tasks/harden-network/${iaas}/terraform/*.tf pcf-pipelines/install-pcf/${iaas}/terraform
}

get_ips() {
  cloudfront_ips=$(curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | jq --arg region "${region}" '[ .prefixes[] | select(.service=="CLOUDFRONT" and .region==$region) | .ip_prefix  ]')
  ec2_ips=$(curl -s https://ip-ranges.amazonaws.com/ip-ranges.json | jq --arg region "${region}" '[ .prefixes[] | select(.service=="EC2" and .region==$region) |  .ip_prefix  ]')
  github_ips=$(curl -s https://api.github.com/meta | jq '.git')
}

copy_templates
get_ips
