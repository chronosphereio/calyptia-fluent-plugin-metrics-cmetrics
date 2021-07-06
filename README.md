# Fluent::Plugin::CMetricsMetrics

[![Testing on Ubuntu](https://github.com/calyptia/fluent-plugin-metrics-cmetrics/actions/workflows/ubuntu-test.yml/badge.svg?branch=main)](https://github.com/calyptia/fluent-plugin-metrics-cmetrics/actions/workflows/ubuntu-test.yml)
[![Testing on macOS](https://github.com/calyptia/fluent-plugin-metrics-cmetrics/actions/workflows/macos-test.yml/badge.svg?branch=main)](https://github.com/calyptia/fluent-plugin-metrics-cmetrics/actions/workflows/macos-test.yml)
[![Testing on Windows](https://github.com/calyptia/fluent-plugin-metrics-cmetrics/actions/workflows/windows-test.yml/badge.svg?branch=main)](https://github.com/calyptia/fluent-plugin-metrics-cmetrics/actions/workflows/windows-test.yml)

A Fluentd plugin which uses [cmetrics](https://github.com/calyptia/cmetrics) context to collect Fluentd metrics.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-metrics-cmetrics'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fluent-plugin-metrics-cmetrics

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/calyptia/fluent-plugin-metrics-cmetrics.
