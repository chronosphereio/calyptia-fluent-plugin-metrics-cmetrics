#
# fluent-plugin-metrics-cmetrics
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'cmetrics'
require 'fluent/plugin'
require 'fluent/plugin/metrics'

module Fluent
  module Plugin
    class CMetricsMetrics < Metrics
      Fluent::Plugin.register_metrics('cmetrics', self)

      attr_reader :cmetrics, :_subsystem # _subsystem for testing.

      config_param :enable_calyptia_metrics_mapping, :bool, default: true

      def initialize
        super
        @cmetrics = nil
        @default_labels_keys = []
        @default_labels_values = []
        @_subsystem = nil
      end

      def configure(conf)
        super

        default_labels.each do |key, value|
          @default_labels_keys << key
          @default_labels_values << value
        end
        # Handle label(s) within <system> directive as default label(s)
        unless labels.empty?
          labels.each do |key, value|
            @default_labels_keys << key
            @default_labels_values << value
          end
        end
        @labels_keys = @default_labels_keys
        @labels_values = @default_labels_values
        if use_gauge_metric
          @cmetrics = ::CMetrics::Gauge.new
          class << self
            alias_method :dec, :dec_gauge
            alias_method :sub, :sub_gauge
          end
        else
          @cmetrics = ::CMetrics::Counter.new
        end
      end

      def create(namespace:, subsystem:, name:, help_text:, labels: {})
        if @enable_calyptia_metrics_mapping
          subsystem = calyptia_metrics_subsystem_mapper(subsystem)
        end
        @cmetrics.create(namespace, subsystem, name, help_text, @labels_keys)
        # Add specified in #create label(s) as static label(s).
        unless labels.empty?
          labels.each do |k,v|
            @cmetrics.add_label(k, v)
          end
        end
      end

      def calyptia_metrics_subsystem_mapper(subsystem)
        case subsystem.to_s
        when "buffer"
          # Calyptia's service should handle buffer metrics as storage.
          subsystem = "storage"
        end
        @_subsystem = subsystem
        subsystem
      end

      def multi_workers_ready?
        true
      end

      def get
        @cmetrics.val(@labels_values)
      end

      def inc
        @cmetrics.inc(@labels_values)
      end

      def dec_gauge
        @cmetrics.dec(@labels_values)
      end

      def add(value)
        @cmetrics.add(value, @labels_values)
      end

      def sub_gauge(value)
        @cmetrics.sub(value, @labels_values)
      end

      def set(value)
        @cmetrics.set(value, @labels_values)
      end
    end
  end
end
