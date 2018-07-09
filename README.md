# Overview

Harden the IaaS environment created by the [PCF pipelines](https://github.com/pivotal-cf/pcf-pipelines).

# Usage

This pipeline assumes you are working with a PCF foundation created by the [PCF pipelines](https://github.com/pivotal-cf/pcf-pipelines)
provided by Pivotal. It provides a single pipeline that improves the security posture of the installed PCF. To use them, edit the file `params.yml` by replacing the text `CHANGEME` with appropriate values. If your Concourse configuration uses a secrets management server, follow the notes in the comments about what values are sensitive.

From there, create the pipeline, unpause it, and kick it off manually.

```
fly -t ${CONCOURSE} set-pipepline -p harden-pcf -c pipeline.yml -l params.yml
fly -t ${CONCOURSE} unpause-pipeline -p harden-pcf
fly -t ${CONCOURSE} trigger-job -j harden-pcf/bootstrap-terraform-state
fly -t ${CONCOURSE} trigger-job -j harden-pcf/harden-infrastructure
```

# Hardening Applied

* Lock down security groups (especially egress rules)
* Create VPC Endpoints for S3 and EC2
* Encrypt S3 buckets
* Encrypt BOSH disks

# Limitations

* Assumes pipelines are downloaded from [pivnet](https://network.pivotal.io).
* Currently supports only AWS.
