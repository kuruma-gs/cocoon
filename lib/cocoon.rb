require 'cocoon/view_helpers'

module Cocoon
  class Railtie < ::Rails::Railtie

    config.before_initialize do
      config.action_view.javascript_expansions[:cocoon] = %w(cocoon)
    end

    # configure our plugin on boot
    initializer "cocoon.initialize" do |app|
      ActionView::Base.send :include, Cocoon::ViewHelpers
    end

  end

  module Sti
    def self.included(base)
      base.extended ClassMethods
      base.instance_eval do
        class_attribute :subclasses
      end
    end
    module ClassMethods
      def has_subclasses(*array)
        raise ArgumentError, "has_suclasses must set subclasses." if !array
        subclasses = array.flatten.map(&:to_s)
      end

      def subclass_new(attributes={})
        type = attributes.delete(:_type)
        return self.new(attributes)  if !type
        raise ArgumentError, "'#{type}' can't be allowed subclass." if !subclasses.include? type
        type.constantize.new(attributes)
      end
    end
  end

end
