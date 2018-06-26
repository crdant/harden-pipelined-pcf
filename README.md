# Overview

Harden the IaaS environment created by [the PCF pipelines](https://github.com/pivotal-cf/pcf-pipelines).

# Usage

Apply the `harden-network` YAML patch harden the IaaS as part of the `install-pcf` pipeline. Use the `harden-director` patch to assure that the created BOSH director is configured securely. There's also an ops file to assure that this repository is available to the pipeline.

Assuming you've arleady edited the `params.yml` file for your installation, the

```
cat ${PCF_PIPELINES_DIR}/install-pcf/aws/pipeline.yml \
  | yaml-patch -o ops/prepare-pipeline.yml -o ops/harden-network.yml -o ops/harden-director.yml \
  > ${PCF_PIPELINES_DIR}/install-pcf/aws/patched-pipeline.yml
cd ${PCF_PIPELINES_DIR}/install-pcf/aws
fly -t ${CONCOURSE} set-pipeline -p deploy-pcf -c patched-pipeline.yml -l params.yml
```

If you want to omit one hardening step or another, leave out that specific ops file. You must apply the `prepare-pipeline` patch to use either of the other patches.

Alternatively, you can create a standalone pipeline to apply these hardening steps. The `standalone` patch will update the `install-pcf` pipeline to refresh the infrastructure state, configure the director, and assure the director is deployed. All other steps of the pipeline will be deleted. Standalone must be applied last so that other patches don't fail.

```
cat ${PCF_PIPELINES_DIR}/install-pcf/aws/pipeline.yml \
  | yaml-patch -o ops/prepare-pipeline.yml -o ops/harden-network.yml -o ops/harden-director.yml -o ops/standalone.yml \
  > ${PCF_PIPELINES_DIR}/install-pcf/aws/harden-pcf.yml
cd ${PCF_PIPELINES_DIR}/install-pcf/aws
fly -t ${CONCOURSE} set-pipeline -p harden-pcf -c harden-pcf.yml -l params.yml
```

*N.B. If you haven't used `yaml-patch` before, be aware that it will sort the keys of all of the hashes in your YAML document. The unexpected sort caused me to lose a couple of hours the first time I used it.*

# Hardening Applied

* Lock down security groups
* Create VPC Endpoints for S3 and EC2
* Encrypt S3 buckets

# Limitations

* Assumes pipeliens are downloaded from [pivnet](https://network.pivotal.io).
* Currently supports only AWS.

# To Do

1. Assure that Cloud Controller and BOSH director have appropriate S3 access
1. Test further
1. Add BOSH disk encryption (likely as another task)

# Warnings

1. *I quickly extracted this from my [bootstrap](https://github.com/crdant/bootstrap) repository and applied minimal testing.
This may bork your PCF environment.*
