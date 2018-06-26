#!/bin/bash

set -eu

copy_templates () {
  cp -R pcf-pipelines-base/* pcf-pipelines
  cp harden-pipelined-pcf/pipelines/tasks/preserve-opsman/${iaas}/terraform/*.tf pcf-pipelines/install-pcf/${iaas}/terraform
}

copy_templates
