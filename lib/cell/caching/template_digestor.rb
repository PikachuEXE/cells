require 'active_support/core_ext'
require 'active_support/cache'
require 'logger'

module Cell
  module Caching
    class TemplateDigestor
      cattr_accessor(:cache_store, instance_reader: true) { ActiveSupport::Cache::MemoryStore.new }
      cattr_accessor(:cache_prefix)

      cattr_accessor(:logger, instance_reader: true)

      def self.digest(name, format, finder, options = {})
        cache_key = [ "cell_template_digestor", cache_prefix, name, format ].compact.join("/")
        cache_store.fetch(cache_key) do
          cache_store.write(cache_key, nil) # Prevent re-entry
          new(name, format, finder, options).digest
        end
      end

      attr_reader :name, :format, :finder, :options

      def initialize(name, format, finder, options = {})
        @name, @format, @finder, @options = name, format, finder, options
      end

      def digest
        Digest::MD5.hexdigest(source).tap do |digest|
          logger.try :debug, "Cache digest for #{name}.#{format}: #{digest}"
        end
      rescue ActionView::MissingTemplate
        logger.try :error, "Couldn't find template for digesting: #{name}.#{format}"
        ''
      end

      private
        def name_for_look_up
          "#{logical_name}.#{format}"
        end

        def logical_name
          name.gsub(%r|/_|, "/")
        end

        def partial?
          options[:partial] || name.include?("/_")
        end

        def source
          template.source
        end

        def template
          @template ||= finder.find(name_for_look_up, [], partial?)
        end
    end
  end
end
