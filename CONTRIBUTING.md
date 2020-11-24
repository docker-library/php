## Contributing to this repository

1. Don't edit the Dockerfiles directly. They are generated using templates.
2. Make any changes to the `*.template` files in the root of the repository.
3. Make sure you've checked the [Requirements](#requirements) below.
4. Run the `./apply-templates.sh` script after making your changes.
5. Once complete, commit all changes to the templates and Dockerfiles.

## Requirements

You will need [Gnu Awk](https://www.gnu.org/software/gawk/) to generate the Dockerfiles from the templates.

To install Gnu Awk on Debian-flavors of Linux:

```
$ apt-get update && apt-get install gawk
```

To install Gnu Awk on Mac/Linux/Windows with [Homebrew](https://brew.sh/):

```
$ brew install gawk
```
