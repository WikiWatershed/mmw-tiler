# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1] - 2026-08-27

### Changed

- Upgrade the CloudFront `titiler-headers` helper Lambda off the deprecated
  `python3.9` runtime (end of support 2025-12-15) to `python3.13`. The FilmDrop
  `cloudfront/custom_origin` module hardcodes this runtime, so it is patched in
  `retrieve_tf_modules.sh` after the modules are vendored ([#18]).

## [1.0] - 2026-08-27

### Changed

- Upgrade the mosaic TiTiler API Lambda from `python3.10` (deprecated by AWS
  Lambda on 2026-10-31) to `python3.12`. The stock FilmDrop module pins the
  runtime and downloads the prebuilt package from the `titiler-mosaicjson`
  GitHub release (which only publishes a `python3.10` build), so
  `retrieve_tf_modules.sh` is patched to set the runtime and fetch a self-built
  `python3.12` package from a public S3 bucket over HTTPS — usable by both the
  staging and prod accounts without credentials ([#17]).

### Added

- Generate MosaicJSON mosaics for the production environment.

## [0.1] - 2024-12-20

### Added

- Initial FilmDrop deployment of TiTiler (the Element84 `titiler-mosaicjson`
  fork) and the FilmDrop Console UI, provisioned with
  `filmdrop-aws-tf-modules` v2.27.0 ([#1]).
- CI/CD to deploy the staging environment (on push to `main` and on `v*` tags)
  and the production environment (on `v*` tags), built as a reusable workflow
  ([#2], [#3], [#4], [#5]).
- Console UI colormap configuration and a configurable TiTiler mosaic tile
  timeout ([#8]).
- Production deployment variables (`prod.tfvars`).

[Unreleased]: https://github.com/WikiWatershed/mmw-tiler/compare/v1.1...HEAD
[1.1]: https://github.com/WikiWatershed/mmw-tiler/compare/v1.0...v1.1
[1.0]: https://github.com/WikiWatershed/mmw-tiler/compare/v0.1...v1.0
[0.1]: https://github.com/WikiWatershed/mmw-tiler/releases/tag/v0.1
[#1]: https://github.com/WikiWatershed/mmw-tiler/pull/1
[#2]: https://github.com/WikiWatershed/mmw-tiler/pull/2
[#3]: https://github.com/WikiWatershed/mmw-tiler/pull/3
[#4]: https://github.com/WikiWatershed/mmw-tiler/pull/4
[#5]: https://github.com/WikiWatershed/mmw-tiler/pull/5
[#8]: https://github.com/WikiWatershed/mmw-tiler/pull/8
[#17]: https://github.com/WikiWatershed/mmw-tiler/pull/17
[#18]: https://github.com/WikiWatershed/mmw-tiler/pull/18
