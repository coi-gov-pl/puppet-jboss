# Puppet smoke tests folder

This folder contains standard Puppet smoke tests that can be run with

```
puppet apply tests/nameoffile.pp --noop
```

All files should execute without any problems, except for those in folder `tests/examples/`.
Examples in that folder require additional resources such as files or wars and we consider that placing them in repository is bad habit. If you want to run tests provide files via for example wget or some other technique.
