# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) 
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.3.3] - 2017-01-17
### Added
- The example project now uses SynqHttpLib for communicating with an example backend to authorize users and make function calls towards the SYNQ Video API

### Changed
- Removed the SynqAPI class
- Update readme


## [0.3.2] - 2016-11-29
### Changed
- Correct wrong date on v0.3.1
- Update after merging to fix conflict


## [0.3.1] - 2016-11-29
### Added
- Add documentation to SQVideoUpload class

### Changed
- PodSpec: Update repo links to point to GitHub repo
- Update readme


## [0.3.0] - 2016-11-23
### Added
- The library will now handle an array of videos for upload
- Update example project to allow selecting multiple videos for upload

### Changed
- Fix incorrect upload progress value
- Update code example


## [0.2.0] - 2016-11-21
### Added
- Add property enableDownloadFromICloud to SynqUploader class.
- Add export progress callback to function uploadVideoArray.
- Add fully functional example project (requires an API key from synq.fm)

### Changed
- Removed success and failure callback from function uploadVideoArray 


## [0.1.0] - 2016-11-15
### Added
- This is the initial version.
