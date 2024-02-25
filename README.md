# auto-changie

Github action to run [changie](https://changie.dev/) and generate changelog with automatic numbering

## How it works

These are the step done by this composite action :

- Setup node with `inputs.node-version`
- Setup changie cli through npm with `inputs.changie-version`
- Initialize changie subtree if not already exist (base on `.changie.yaml` existance)
- Retrieve all commit since last commit contained in last changie release version's file, or since beginning if not release have been done yet.
- Create a changie entry of type Changed for each commit of previous step
- Batch all change in a new automatic version
- Merge all version and update global `CHANGELOG.md` file


## Usage example

```yaml
name: Changelog generator

on:
  push:
    branches:
      - main
      - master

jobs:
  build:
    if: "contains(github.event.head_commit.message, 'CI') != true"
    steps:
      - uses: action/checkout@<latest_tag>
        with:
          fetch-depth: 0
          fetch-tags: false
          
      # ... do some CI habitual stuff
          
      - uses: RouxAntoine/auto-changie@<latest_tag>

      - name: Push changelog
        uses: stefanzweifel/git-auto-commit-action@<latest_tag>
        with:
          commit_message: "CI: Push updated changelog"
```

This pipeline clone code update changelog with auto-changie and push it to main thanks to [git-auto-commit-action](https://github.com/stefanzweifel/git-auto-commit-action).

> Notice the use of `fetch-depth: 0` should be set. 
> Indeed without this not all commit are retrieve and auto-changie fail to find all commit updated since previous run.