require 'rails/generators'
require 'rails/generators/named_base'

module Effigy
  module Generators
    # Base generator for Effigy generators. Setups up the source root.
    class Base < ::Rails::Generators::NamedBase
      # @return [String] source root for tempates within an effigy generator
      def self.source_root
        @_effigy_source_root ||=
          File.expand_path(File.join(File.dirname(__FILE__),
                                     generator_name,
                                     'templates'))
      end
    end
  end
end

