# NumPy wheels and release tooling

This repository contains what is needed to build release artifacts (wheels and
sdist) for the official [NumPy releases to
PyPI](https://pypi.org/project/numpy/) as well as nightly wheel builds which
are uploaded to
[anaconda.org/scientific-python-nightly-wheels/numpy](https://anaconda.org/scientific-python-nightly-wheels/numpy).

This repository is minimal on purpose, for security reasons it contains only what is absolutely necessary. The repository settings are stricter than on the main [numpy/numpy](https://github.com/numpy/numpy/) repository, for example:

- only the release & CI team has write access
- for PRs from anyone without write access, CI will always need manual approval
- linear history is required
- GitHub actions are whitelisted, only the necessary ones will be allowed
- no caching allowed, only clean builds from scratch
- no self-hosted runners are allowed

See [numpy#29178](https://github.com/numpy/numpy/issues/29178) for more context.


## Branches and tags

TODO: describe how branches/tags in this repo correspond to the main branch and
release tags on the main repo.


## Build reproducibility

Wheel builds being fully reproducible is a long-term goal for this repository.
All dependencies and actions must be pinned, which allows us to already be
close to full reproducibility. However, we don't (yet) have full control over
all ingredients that go into a wheel build, e.g. the containers which GitHub
Actions provide may change over time.


## Trusted publishing and attestations

TODO


## Software Bill of Materials

TODO


## Security

To report a security vulnerability for NumPy itself, please see
[the security policy on the main repo](https://github.com/numpy/numpy/?tab=security-ov-file#readme).

To discuss a supply chain security related topic for the code in this
repository, please open an issue on this repository if it can be discussed in
public, and otherwise please follow the security policy on the main repo.
