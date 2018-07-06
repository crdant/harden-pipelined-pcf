resource "aws_kms_key" "blobstore_encryption" {
  description             = "Encrypt S3 buckets used for blobstores"
  deletion_window_in_days = 10

  tags {
      Name = "${var.prefix}-blobstore-encryption"
  }
}

data "aws_s3_bucket" "bosh" {
  bucket = "${var.prefix}-bosh"
}

data "aws_s3_bucket" "buildpacks" {
  bucket = "${var.prefix}-buildpacks"
}

data "aws_s3_bucket" "droplets" {
  bucket = "${var.prefix}-droplets"
}

data "aws_s3_bucket" "packages" {
  bucket = "${var.prefix}-packages"
}

data "aws_s3_bucket" "resources" {
  bucket = "${var.prefix}-resources"
}
