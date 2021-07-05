# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in fluent-plugin-metrics-cmetrics.gemspec
gemspec

local_gemfile = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.exist?(local_gemfile)
  puts "Loading Gemfile.local ..." if $DEBUG # `ruby -d` or `bundle -v`
  instance_eval File.read(local_gemfile)
end
