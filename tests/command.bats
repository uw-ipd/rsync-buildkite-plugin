#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment to enable stub debug output:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "pre-command rsync" {
  stub rsync \
    "id@host:/source/* local/ : echo rsync down"

  export BUILDKITE_PLUGIN_RSYNC_PRE="id@host:/source/* local/"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "rsync down"

  unstub rsync
  unset BUILDKITE_PLUGIN_RSYNC_PRE
}

@test "pre-command rsync multiple" {
  stub rsync \
    "id@host:/source/0 0 : echo rsync down" \
    "id@host:/source/1 1 : echo rsync down" \
    "id@host:/source/2 2 : echo rsync down" 

  export BUILDKITE_PLUGIN_RSYNC_PRE_0="id@host:/source/0 0"
  export BUILDKITE_PLUGIN_RSYNC_PRE_1="id@host:/source/1 1"
  export BUILDKITE_PLUGIN_RSYNC_PRE_2="id@host:/source/2 2"
  run "$PWD/hooks/pre-command"

  assert_success
  assert_output --partial "rsync down"

  unstub rsync
  unset BUILDKITE_PLUGIN_RSYNC_PRE_0
  unset BUILDKITE_PLUGIN_RSYNC_PRE_1
  unset BUILDKITE_PLUGIN_RSYNC_PRE_2
}

@test "Post-command rsync" {
  stub rsync \
    "--include=*/ --include=*.log --exclude=* local/ id@host:/target : echo rsync up"

  export BUILDKITE_PLUGIN_RSYNC_DEBUG=true
  export BUILDKITE_PLUGIN_RSYNC_POST="--include=*/ --include=*.log --exclude=* local/ id@host:/target"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "rsync up"

  unstub rsync
  unset BUILDKITE_PLUGIN_RSYNC_POST
}

@test "post-command rsync multiple" {
  stub rsync \
    "--include=0/ --include=*.log --exclude=* local/ id@host:/target : echo rsync up" \
    "--include=1/ --include=*.log --exclude=* local/ id@host:/target : echo rsync up" \
    "--include=2/ --include=*.log --exclude=* local/ id@host:/target : echo rsync up"

  export BUILDKITE_PLUGIN_RSYNC_POST_0="--include=0/ --include=*.log --exclude=* local/ id@host:/target"
  export BUILDKITE_PLUGIN_RSYNC_POST_1="--include=1/ --include=*.log --exclude=* local/ id@host:/target"
  export BUILDKITE_PLUGIN_RSYNC_POST_2="--include=2/ --include=*.log --exclude=* local/ id@host:/target"
  run "$PWD/hooks/post-command"

  assert_success
  assert_output --partial "rsync up"

  unstub rsync
  unset BUILDKITE_PLUGIN_RSYNC_POST_0
  unset BUILDKITE_PLUGIN_RSYNC_POST_1
  unset BUILDKITE_PLUGIN_RSYNC_POST_2
}
