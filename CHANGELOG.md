# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] - 2025-12-11

### Fixed

- Hammer installed through Wally couldn't find the Jecs linker module

## [0.3.0] - 2025-11-18

### Added

- Added a `delete` method to the ref utility
- Added support for callback signals to the collect utility
- Added support for object-oriented disconnects to the collect utility
- Added the Jecs query observer & monitor utility
- Added interval utility, which allows for throttling systems to run every n seconds
- Added an IsA relationship utility, which allows for transitive inheritance relationships, read more at https://www.flecs.dev/flecs/md_docs_2Relationships.html#the-isa-relationship

### Changed

- Made the collect utility work for the V2 Luau type solver
- Migrated to Jecs v0.9.0

### Removed

- Removed cleanup functions from the ref utility, superseded by the `delete` method
- Removed observers, now native in Jecs
- Removed the tracker utility, considering it's only use was replication, for which the go to should be the [replecs](https://github.com/PepeElToro41/replecs) library

### Fixed

- `@pkg` alias inside packaged library, contributed by @UtterlyTerrible in #1
