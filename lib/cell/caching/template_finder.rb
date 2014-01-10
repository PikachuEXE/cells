module Cell
  module Caching
    class TemplateFinder
      # @return [ActionView::Template]
      def self.find(name, cell, options = {})
        new(name, cell, options).find
      end

      attr_reader :name, :cell, :options

      def initialize(name, cell, options = {})
        @name, @cell, @options = name, cell, options

        finder.formats = [format] if format
      end

      def find
        finder.find(logical_name, prefixes, partial?)
      end

      private
        def logical_name
          name.gsub(%r|/_|, "/")
        end

        def partial?
          options[:partial] || name.include?("/_")
        end

        def prefixes
          cell._prefixes
        end

        def format
          options[:format]
        end

        def finder
          cell.lookup_context
        end
    end
  end
end
