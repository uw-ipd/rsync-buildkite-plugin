# `rsync` Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) for
performing file transfers via
[`rsync`](https://linux.die.net/man/1/rsync). The plugin invokes `rsync`
in the `pre` or `post` command phase to provide an artifact-like upload
and download capacity.

## Examples

Upload a build product directory into a build-specific output directory on
a remote store:

```yml
steps:
  - plugins:
      - uw-ipd/rsync#v0.1:
          post: "-Rrv bin remote:/build/${BUILDKITE_BUILD_NUMBER}"
```

Upload a glob of files, note that artifact-path extended globbing (eg.
`path/**/*.log`) is *not* supported:

```yml
steps:
  - plugins:
      - uw-ipd/rsync#v0.1:
          post: "-Rrv log/*/*.log remote:/build/${BUILDKITE_BUILD_NUMBER}"
```

`${VAR}` is interpolated at pipeline-upload time, not step evaluation
time. Use `$${VAR}` to perform step-time interpolation of environment
variables:

```yml
steps:
  - plugins:
      - uw-ipd/rsync#v0.1:
          post: "-Rrv bin remote:/build/$${BUILDKITE_JOB_ID}"
```

Upload via multiple invocations:

```yml
steps:
  - plugins:
      - uw-ipd/rsync#v0.1:
          post:
           - "-Rrv bin remote:/build/${BUILDKITE_BUILD_NUMBER}"
           - "-Rrv logs/*/*.txt remote:/build/${BUILDKITE_BUILD_NUMBER}/$${BUILDKITE_JOB_ID}"
```

Download *before* a command executes via the `pre` step:

```yml
steps:
  - plugins:
      - uw-ipd/rsync#v0.1:
          pre: "-rv remote:/build/ccache ./ccache"
```


## Ugly Hacks

From `man rsync`, "Rsync is a fast and extraordinarily versatile file
copying tool [...] it offers a large number of options that control every
aspect of its behavior and permit very flexible specification."

:trollface:

Rsync does *not* support creation of nested output directories. Create
a nested output directory via repeated "no-op" copies: 

```yml
steps:
  - plugins:
      - uw-ipd/rsync#v0.1:
          post:
            - "-Rrv --exclude=* . remote:/build/artifacts"
            - "-Rrv --exclude=* . remote:/build/artifacts/${BUILDKITE_BRANCH}"
            - "-Rrv --exclude=* . remote:/build/artifacts/${BUILDKITE_BRANCH}/${BUILDKITE_BUILD_NUMBER}"
            - "-Rrv bin remote:/build/artifacts/${BUILDKITE_BRANCH}/${BUILDKITE_BUILD_NUMBER}"
```

Create a nested output directory via the "rsync-path trick":

```yml
steps:
  - plugins:
      - uw-ipd/rsync#v0.1:
          post: "--rsync-path="mkdir -p /build/artifacts/${BUILDKITE_BRANCH}/${BUILDKITE_BUILD_NUMBER} && rsync" -Rrv bin remote:/build/artifacts/${BUILDKITE_BRANCH}/${BUILDKITE_BUILD_NUMBER}"
```

## Configuration

### `pre`

An rsync argument string, or array of rsync argument strings, to be
executed before `command`.

### `post`

An rsync argument string, or array of rsync argument strings, to be
executed after `command`.

## License

MIT (see [LICENSE](LICENSE))
