# Contributing to this repository

1. Don't edit the Dockerfiles directly. They are generated using templates.
2. Make any changes to the `*.template` files in the root of the repository.
3. Make sure you've checked the [Requirements](#requirements) below.
4. Run the `./apply-templates.sh` script after making your changes.
5. Once complete, (review and) commit all changes to the templates and Dockerfiles.

## Requirements

You will need the following software packages to run the [`./apply-templates.sh`](/apply-templates.sh) script.

- [GNU awk](https://www.gnu.org/software/gawk/) available as `gawk`.
- [`jq`](https://stedolan.github.io/jq/)
- A recent version of Bash
