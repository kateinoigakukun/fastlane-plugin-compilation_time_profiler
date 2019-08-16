# compilation_time_profiler plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-compilation_time_profiler)

A fastlane plugin that profiles compilation performance of `swiftc` using `-debug-time-compilation`. 

This action parse profiling table produced by `swiftc` and returns array of it.

```
===-------------------------------------------------------------------------===
                               Swift compilation
===-------------------------------------------------------------------------===
  Total Execution Time: 0.0038 seconds (0.0031 wall clock)

   ---User Time---   --System Time--   --User+System--   ---Wall Time---  --- Name ---
   0.0013 ( 57.0%)   0.0012 ( 74.3%)   0.0025 ( 64.2%)   0.0017 ( 54.2%)  LLVM pipeline
   0.0005 ( 23.9%)   0.0002 ( 10.8%)   0.0007 ( 18.5%)   0.0007 ( 23.3%)  Type checking / Semantic analysis
   0.0003 ( 13.9%)   0.0001 (  9.1%)   0.0005 ( 11.9%)   0.0005 ( 15.0%)  Serialization, swiftmodule
   0.0001 (  2.6%)   0.0000 (  2.9%)   0.0001 (  2.7%)   0.0001 (  4.2%)  Parsing
   0.0000 (  0.9%)   0.0000 (  1.9%)   0.0001 (  1.3%)   0.0001 (  1.7%)  Serialization, swiftdoc
   0.0000 (  0.9%)   0.0000 (  0.3%)   0.0000 (  0.7%)   0.0000 (  0.8%)  SIL optimization
   0.0000 (  0.4%)   0.0000 (  0.4%)   0.0000 (  0.4%)   0.0000 (  0.6%)  SILGen
   0.0000 (  0.2%)   0.0000 (  0.3%)   0.0000 (  0.2%)   0.0000 (  0.2%)  Name binding
   0.0000 (  0.0%)   0.0000 (  0.0%)   0.0000 (  0.0%)   0.0000 (  0.0%)  SIL verification, post-optimization
   0.0000 (  0.0%)   0.0000 (  0.0%)   0.0000 (  0.0%)   0.0000 (  0.0%)  AST verification
   0.0000 (  0.0%)   0.0000 (  0.0%)   0.0000 (  0.0%)   0.0000 (  0.0%)  SIL verification, pre-optimization
   0.0022 (100.0%)   0.0016 (100.0%)   0.0038 (100.0%)   0.0031 (100.0%)  Total
```

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-compilation_time_profiler`, add it to your project by running:

```bash
fastlane add_plugin compilation_time_profiler
```

**Note**: Please specify `buildlog_path` to build action like `run_tests` or `build_ios_app`


```ruby
buildlog_dir = Dir.mktmpdir

compilation_time_profiler(
  buildlog_path: buildlog_dir,
  action: proc do # build action like run_tests or build_ios_app
    run_tests(
      buildlog_path: buildlog_dir,
      scheme: "AppScheme",
      workspace: "App.xcworkspace"
    )
  end
)
```

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
