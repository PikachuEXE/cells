require 'active_support/core_ext'
require 'active_support/cache'
require 'logger'

module Cell
  module Caching
    class TemplateDigestor
      cattr_accessor(:cache_store, instance_reader: true) { ActiveSupport::Cache::MemoryStore.new }
      cattr_accessor(:cache_prefix)

      cattr_accessor(:logger, instance_reader: true)

      def self.digest(name, cell, options = {})
        new(name, cell, options).digest
      end

      attr_reader :name, :cell, :options

      def initialize(name, cell, options = {})
        @name, @cell, @options = name, cell, options
      end

      def digest
        format = options[:format]
        cache_key = [ "cell_template_digestor", cache_prefix, name, format ].compact.join("/")

        cache_store.fetch(cache_key) do
          cache_store.write(cache_key, nil) # Prevent re-entry
          begin
            Digest::MD5.hexdigest(source).tap do |digest|
              logger.try :debug, "Cache digest for #{name}.#{format}: #{digest}"
            end
          rescue ActionView::MissingTemplate
            logger.try :error, "Couldn't find template for digesting: #{name}.#{format}"
            ''
          end
        end
      end

      private
        def source
          template.source
        end

        def template
          @template ||= TemplateFinder.find(name, cell, options)
        end
    end
  end
end
