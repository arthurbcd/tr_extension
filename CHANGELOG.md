# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - Aug 16, 2023

### Added

- Added [AsyncConfig] as config parameter of [Async] widget. This class for now on will hold all specific AsyncWidget configs.
- Added AsyncConfig.of(context);
- Added AsyncConfig.maybeOf(context);

### Changed

- Now WidgetBuilder is used on all state builders widgets for consistency.

### Removed

- [AsyncButtonConfig] will no longer be set with static methods. Use [AsyncConfig] instead through [Async] widget inheritance.
- Removed AsyncButton.setConfig & others.

## [0.2.0] - Aug 15, 2023

### Added

- Added [Async] widget for void async tasks, utilities and inheritance (you can provide custom loader and error).

### Changed

- Breaking change: AsyncBuilder now has one single constructor.

- AsyncBuilder.future, renamed to -> AsyncBuilder.getFuture.

- AsyncBuilder.stream, renamed to -> AsyncBuilder.getStream.

## [0.1.0] - Jul 10, 2023

### Changed

- Bump support to Dart SDK 2.17 <4.0 (flutter 3.0)

## [0.0.1] - Jul 9, 2023

### Added

- Initial pre-release.
