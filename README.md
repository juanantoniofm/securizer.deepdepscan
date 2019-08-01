# Securizer

A system to gather together a bunch of tools for code quality and static code
analysis, that can be set up using a githook and a ssh key.

## Status

Currently is just an idea, in testing for possible solutions

## Dev  Notes

### Folder structure

The structure of folders, due to this not being just "software" but infra and
software together, will differ a bit from your usual hierarchy.

- ops

  Things to ease the usage of this very repo. Setup, configuration, init, etc

- infra

  Infrastructure. The terraform code to provision the machine that will host
  services and run the workload.

- docs

  Documentation, design rationale, pending work, etc

- provision

  Tools and things for the provisioning stage.

- .secrets

  containing possible secret files like keys, tokens, etc. never to be commited.

- 
