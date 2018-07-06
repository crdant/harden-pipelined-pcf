resource "aws_kms_key" "blobstore_encryption" {
  description             = "Encrypt S3 buckets used for blobstores"
  deletion_window_in_days = 10

  tags {
      Name = "${var.prefix}-blobstore-encryption"
  }
}

locals {
  encryption_configuration = <<JSON
    {
      "Rules": [
        {
          "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "aws:kms",
            "KMSMasterKeyID": "${aws_kms_key.blobstore_encryption.arn}"
          }
        }
      ]
    }
  JSON
}

data "aws_s3_bucket" "bosh" {
  bucket = "${var.prefix}-bosh"
}

resource "null_resource" "encrypt_bosh_blobstore" {
  triggers = {
    key_arn = "${aws_kms_key.blobstore_encryption.arn}"
  }

  provisioner "local-exec" {
    command = <<CMD
      export AWS_ACCESS_KEY_ID="${var.access_key_id}"
      export AWS_SECRET_ACCESS_KEY="${var.secret_access_key}"
      aws s3api put-bucket-encryption --bucket "${data.aws_s3_bucket.bosh.id}" --server-side-encryption-configuration '${local.encryption_configuration}'
    CMD
  }
}

data "aws_s3_bucket" "buildpacks" {
  bucket = "${var.prefix}-buildpacks"
}

resource "null_resource" "encrypt_buildpacks_blobstore" {
  triggers = {
    key_arn = "${aws_kms_key.blobstore_encryption.arn}"
  }

  provisioner "local-exec" {
    command = <<CMD
      export AWS_ACCESS_KEY_ID="${var.access_key_id}"
      export AWS_SECRET_ACCESS_KEY="${var.secret_access_key}"
      aws s3api put-bucket-encryption --bucket "${data.aws_s3_bucket.buildpacks.id}" --server-side-encryption-configuration '${local.encryption_configuration}'
    CMD
  }
}


data "aws_s3_bucket" "droplets" {
  bucket = "${var.prefix}-droplets"
}

resource "null_resource" "encrypt_droplets_blobstore" {
  triggers = {
    key_arn = "${aws_kms_key.blobstore_encryption.arn}"
  }

  provisioner "local-exec" {
    command = <<CMD
      export AWS_ACCESS_KEY_ID="${var.access_key_id}"
      export AWS_SECRET_ACCESS_KEY="${var.secret_access_key}"
      aws s3api put-bucket-encryption --bucket "${data.aws_s3_bucket.droplets.id}" --server-side-encryption-configuration '${local.encryption_configuration}'
    CMD
  }
}

data "aws_s3_bucket" "packages" {
  bucket = "${var.prefix}-packages"
}

resource "null_resource" "encrypt_packages_blobstore" {
  triggers = {
    key_arn = "${aws_kms_key.blobstore_encryption.arn}"
  }

  provisioner "local-exec" {
    command = <<CMD
      export AWS_ACCESS_KEY_ID="${var.access_key_id}"
      export AWS_SECRET_ACCESS_KEY="${var.secret_access_key}"
      aws s3api put-bucket-encryption --bucket "${data.aws_s3_bucket.packages.id}" --server-side-encryption-configuration '${local.encryption_configuration}'
    CMD
  }
}

data "aws_s3_bucket" "resources" {
  bucket = "${var.prefix}-resources"
}

resource "null_resource" "encrypt_resources_blobstore" {
  triggers = {
    key_arn = "${aws_kms_key.blobstore_encryption.arn}"
  }

  provisioner "local-exec" {
    command = <<CMD
      export AWS_ACCESS_KEY_ID="${var.access_key_id}"
      export AWS_SECRET_ACCESS_KEY="${var.secret_access_key}"
      aws s3api put-bucket-encryption --bucket "${data.aws_s3_bucket.resources.id}" --server-side-encryption-configuration '${local.encryption_configuration}'
    CMD
  }
}
