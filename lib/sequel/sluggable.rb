module Sequel
  module Plugins
    module Sluggable

      class Util
        extend Applyance::Lib::Strings
      end

      # Plugin configuration
      def self.configure(model, opts={})
        model.sluggable_options = opts
        model.sluggable_options.freeze
      end

      module ClassMethods
        attr_reader :sluggable_options

        # Propagate settings to the child classes
        #
        # @param [Class] Child class
        def inherited(klass)
          super
          klass.sluggable_options = self.sluggable_options.dup
        end

        # Set the plugin options
        #
        # Options:
        # @param [Hash] plugin options
        # @option source    [Symbol] :Column to get value to be slugged from.
        def sluggable_options=(options)
          raise ArgumentError, "You must provide :source column" unless options[:source]
          options[:source]    = options[:source].to_sym
          @sluggable_options  = options
        end
      end

      module InstanceMethods

        # Create slug
        def before_validation
          super
          source = self.class.sluggable_options[:source]
          self._slug = Util.to_slug(self.send(source), '')
          object_count = self.class.where(:'_slug' => self._slug).exclude(:id => self.id).count
          self.slug = (object_count == 0) ? self._slug : "#{self._slug}-#{object_count + 1}"
        end

      end

    end
  end
end
