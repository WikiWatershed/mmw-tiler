#!/usr/bin/env bash
set -Eeuo pipefail
set -x # print each command before executing

FILMDROP_TERRAFORM_RELEASE=$1

wget -qO- https://github.com/Element84/filmdrop-aws-tf-modules/archive/refs/tags/${FILMDROP_TERRAFORM_RELEASE}.tar.gz | tar xvz
mkdir -p modules
mkdir -p profiles
cp filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/filmdrop.tf .
cp filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/providers.tf .
cp filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/inputs.tf .
cp -r filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/modules .
cp -r filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}/profiles .
rm -rf filmdrop-aws-tf-modules-${FILMDROP_TERRAFORM_RELEASE:1}

# --- MMW patch (issue #15): run the mosaic titiler Lambda on python3.12 ---
# The stock FilmDrop module pins python3.10 and downloads the prebuilt zip from
# the titiler-mosaicjson GitHub release, which only publishes lambda-python3.10.zip.
# We host a self-built lambda-python3.12.zip in a public S3 bucket, so bump the
# runtime and fetch the artifact over HTTPS from there (no AWS creds required, so
# the same URL works for both the staging and prod accounts). Remove once this is
# supported upstream.
python3 - <<'PYEOF'
import pathlib

mod = pathlib.Path("modules/mosaic-titiler")

# 1) Default the Lambda runtime to python3.12.
inputs = mod / "inputs.tf"
text = inputs.read_text()
text = text.replace('default     = "python3.10"', 'default     = "python3.12"')
inputs.write_text(text)

# 2) Fetch the prebuilt zip from S3 instead of the GitHub release.
tf = mod / "titler-mosaicjson.tf"
text = tf.read_text()
old = (
    'which wget || echo "wget is required, but not found - this is going to fail..."\n'
    'wget --secure-protocol=TLSv1_2 --quiet \\\n'
    '  https://github.com/Element84/titiler-mosaicjson/releases/download/${var.titiler_mosaicjson_release_tag}/lambda-${var.lambda_runtime}.zip \\\n'
    '  -O ${path.module}/lambda/${var.titiler_mosaicjson_release_tag}-lambda-${var.lambda_runtime}.zip'
)
new = (
    '# MMW: fetch the prebuilt zip from our public S3 bucket over HTTPS\n'
    'which wget || echo "wget is required, but not found - this is going to fail..."\n'
    'wget --secure-protocol=TLSv1_2 --quiet \\\n'
    '  https://mmw-titiler-lambda-zip.s3.us-east-1.amazonaws.com/lambda-${var.lambda_runtime}.zip \\\n'
    '  -O ${path.module}/lambda/${var.titiler_mosaicjson_release_tag}-lambda-${var.lambda_runtime}.zip'
)
assert old in text, "mosaic-titiler wget block not found; upstream module layout changed"
tf.write_text(text.replace(old, new))

# 3) The CloudFront headers helper Lambda is hardcoded to python3.9 (deprecated
#    2025-12-15) in headers.tf, with no variable to override it and no change in
#    newer FilmDrop releases. Bump it to a supported runtime; the handler only
#    uses os + boto3 (bundled in every runtime), so it is runtime-agnostic.
#    python3.13 (not 3.14): the pinned AWS provider's `terraform validate` runtime
#    enum tops out at 3.13, though both deprecate on 2029-06-30.
headers = pathlib.Path("modules/cloudfront/custom_origin/headers.tf")
htext = headers.read_text()
assert '"python3.9"' in htext, "headers.tf python3.9 runtime not found; upstream module layout changed"
headers.write_text(htext.replace('"python3.9"', '"python3.13"'))

print("MMW patch applied: mosaic-titiler runtime=python3.12 (S3 source); headers lambda runtime=python3.13")
PYEOF