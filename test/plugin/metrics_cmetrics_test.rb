# frozen_string_literal: true

require "test_helper"
require 'fluent/env'
require 'fluent/test'
require "fluent/test/helpers"

class Fluent::Plugin::CMetricsMetricsTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  test "VERSION" do
    assert do
      ::Fluent::Plugin::CMetrics.const_defined?(:VERSION)
    end
  end

  sub_test_case 'configure' do
    test "configured for counter mode" do
      m = Fluent::Plugin::CMetricsMetrics.new
      m.configure(config_element('metrics', '', {"labels" => {test: "test-unit", language: "Ruby"}}))

      assert_false m.use_gauge_metric
      assert_equal({agent: "Fluentd", hostname: "#{Socket.gethostname}"},
                   m.default_labels)
      assert_equal({test: "test-unit", language:  "Ruby"},
                   m.labels)
      assert_equal([:agent, :hostname, :test, :language], m.instance_variable_get(:@labels_keys))
      assert_equal(["Fluentd", "#{Socket.gethostname}", "test-unit", "Ruby"],
                   m.instance_variable_get(:@labels_values))
      assert_true m.has_methods_for_counter
      assert_false m.has_methods_for_gauge
    end

    test "configured for gauge mode" do
      m = Fluent::Plugin::CMetricsMetrics.new
      m.use_gauge_metric = true
      m.configure(config_element('metrics', '', {"labels" => {test: "rspec", middleware: "Fluentd"}}))

      assert_true m.use_gauge_metric
      assert_equal({agent: "Fluentd", hostname: "#{Socket.gethostname}"},
                   m.default_labels)
      assert_equal({test: "rspec", middleware: "Fluentd"},
                   m.labels)
      assert_equal([:agent, :hostname, :test, :middleware], m.instance_variable_get(:@labels_keys))
      assert_equal(["Fluentd", "#{Socket.gethostname}", "rspec", "Fluentd"],
                   m.instance_variable_get(:@labels_values))
      assert_false m.has_methods_for_counter
      assert_true m.has_methods_for_gauge
    end

    test "should replace subsystem name with storage" do
      m = Fluent::Plugin::CMetricsMetrics.new
      m.configure(config_element('metrics', '', {"labels" => {test: "rspec", middleware: "Fluentd"}, "enable_calyptia_metrics_mapping" => true}))
      m.create(namespace: "Fluentd", subsystem: "buffer", name: "subsystem replacement test", help_text: "CMtrics metrics plugin subsystem replacement tesing")
      assert_equal "storage", m._subsystem
    end

    test "shouldn't replace subsystem name with storage" do
      m = Fluent::Plugin::CMetricsMetrics.new
      m.configure(config_element('metrics', '', {"labels" => {test: "rspec", middleware: "Fluentd"}, "enable_calyptia_metrics_mapping" => true}))
      m.create(namespace: "Fluentd", subsystem: "notbuffer", name: "subsystem replacement test", help_text: "CMtrics metrics plugin subsystem replacement tesing")
      assert_equal "notbuffer", m._subsystem
    end
  end

  sub_test_case "Metrics" do
    sub_test_case "counter" do
      setup do
        @m = Fluent::Plugin::CMetricsMetrics.new
        @m.configure(config_element('metrics', '', {}))
        @m.create(namespace: "Fluentd", subsystem: "cmetrics_metrics plugin testing", name: "counter test", help_text: "CMtrics metrics plugin counter mode tesing")
      end

      test '#configure' do
        assert_true @m.has_methods_for_counter
        assert_false @m.has_methods_for_gauge
      end

      test "encoders" do
        assert do
          @m.cmetrics.to_s
        end
        assert do
          @m.cmetrics.to_influx
        end
        assert do
          @m.cmetrics.to_prometheus
        end
      end

      test 'all operations work well' do
        assert_equal nil, @m.get
        assert_equal true, @m.inc

        @m.add(20)
        assert_equal 21, @m.get
        assert_raise NotImplementedError do
          @m.dec
        end

        @m.set(100)
        assert_equal 100, @m.get

        @m.set(10)
        assert_equal 100, @m.get # On counter, value should be overwritten bigger than stored one.
        assert_raise NotImplementedError do
          @m.sub(11)
        end
      end
    end

    sub_test_case "gauge" do
      setup do
        @m = Fluent::Plugin::CMetricsMetrics.new
        @m.use_gauge_metric = true
        @m.configure(config_element('metrics', '', {}))
        @m.create(namespace: "Fluentd", subsystem: "cmetrics_metrics plugin testing", name: "gauge test", help_text: "CMtrics metrics plugin gauge mode tesing")
      end

      test '#configure' do
        assert_false @m.has_methods_for_counter
        assert_true @m.has_methods_for_gauge
      end

      test "encoders" do
        assert do
          @m.cmetrics.to_s
        end
        assert do
          @m.cmetrics.to_influx
        end
        assert do
          @m.cmetrics.to_prometheus
        end
      end

      test 'all operations work well' do
        assert_equal nil, @m.get
        assert_equal true, @m.inc

        @m.add(20)
        assert_equal 21, @m.get
        @m.dec
        assert_equal 20, @m.get

        @m.set(100)
        assert_equal 100, @m.get

        @m.sub(11)
        assert_equal 89, @m.get

        @m.set(10)
        assert_equal 10, @m.get # On gauge, value always should be overwritten.
      end
    end
  end
end
