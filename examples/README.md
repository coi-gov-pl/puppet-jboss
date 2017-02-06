# Puppet smoke tests folder

This folder contains standard Puppet smoke tests that can be run with

```
puppet apply tests/[name-of-test].pp --noop
```

All files should execute without any problems.

**CAUTION!** `deploy.pp` and `resourceadapter.pp` smoke tests fetches some example artifacts from Maven Central repository using `wget`.
