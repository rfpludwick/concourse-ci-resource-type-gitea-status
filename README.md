# Concourse CI Resource Type - Gitea Status

This is only intended to update Gitea status on the `out` action for a Concourse
CI pipeline. Feel free to contribute if you like, but this is offered without support
at this time. Tested against Gitea 1.20.5.

## Source Configuration

* `protocol`: *Required.* Typically `https://`
* `host`: *Required*. The Gitea hostname.
* `username`: *Required.* The Gitea username.
* `password`: *Required.* Git Gitea password.

## Behavior

### `check`: No operation

### `in`: No operation

### `out`: Update Gitea commit status

Sends a structured message to Gitea based on the build state.

#### Parameters

* `build_state`: *Required.* The type of state to send to Gitea. Documentation available
at [Gitea's API docs](https://docs.gitea.com/api/1.20/#tag/repository/operation/repoCreateStatus).
* `repo`: *Required.* The repository used as input. From a git clone, typically.
* `build_status_prefix`: *Optional.* A string value to prefix to the build status
check name.
* `build_status_branch_suffix`: *Optional.* A boolean flag to append the branch
name to the end of the status check name as a suffix.
* `build_status_description_`: *Optional.* A string value to set as status for the
build status check.

## Example

```yaml
resource_types:
  - name: "gitea-status"
    type: "registry-image"
    source:
      repository: "rfpludwick/concourse-ci-resource-type-gitea-status"
resources:
  - name: repo
    type: git
    icon: github
    source:
      uri: ((gitea.repo))
      branch: main
  - name: "gitea-status"
    type: "gitea-status"
    icon: "source-commit"
    source:
      protocol: "https://"
      host: ((gitea.host))
      username: ((gitea.username))
      password: ((gitea.password))
jobs:
  - name: "do-something"
    plan:
      - get: repo
        trigger: true
      - &gitea_base
        put: "gitea-status"
        inputs:
          - repo
        params:
          repo: repo
          build_state: pending
          build_status_prefix: concourse/
          build_status_branch_suffix: true
          build_status_description: Some useful description about the check
    on_success:
      <<: *gitea_base
      params:
        repo: repo
        build_state: success
        build_status_prefix: concourse/
        build_status_branch_suffix: true
          build_status_description: Some useful description about the check
    on_failure:
      <<: *gitea_base
      params:
        repo: repo
        build_state: failure
        build_status_prefix: concourse/
        build_status_branch_suffix: true
          build_status_description: Some useful description about the check
    on_abort:
      <<: *gitea_base
      params:
        repo: repo
        build_state: warning
        build_status_prefix: concourse/
        build_status_branch_suffix: true
          build_status_description: Some useful description about the check
    on_error:
      <<: *gitea_base
      params:
        repo: repo
        build_state: error
        build_status_prefix: concourse/
        build_status_branch_suffix: true
          build_status_description: Some useful description about the check
```
