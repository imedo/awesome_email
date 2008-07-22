module ActionMailer
  module Layouts
    module ClassMethods
      # none
    end
    
    module InstanceMethods
     
      def render_message_with_layouts(method_name, body)
        return render_message_without_layouts(method_name, body) if @layout.blank?
        template = initialize_template_class body
        file_name = extend_with_mailer_name(method_name)
        template.instance_variable_set(:@content_for_layout, template.render(:file => file_name))
        extension_parts = method_name.split('.')[1..-1]
        render_template_for_extension_parts template, extension_parts
      end
      
    protected
      def render_template_for_extension_parts(template, extension_parts)
        while !extension_parts.blank?
          file_name = File.join("layouts", "mailers", ([@layout.to_s] + extension_parts).join('.'))
          return template.render(file_name) if template.file_exists?(file_name)
          extension_parts.shift
        end
        raise "Layout #{@layout} not found"
      end

      def extend_with_mailer_name(template_name)
        result = template_name =~ /\// ? template_name : "#{mailer_name}/#{template_name}"
        result
      end
    end
    
    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
    
      receiver.class_eval do
        adv_attr_accessor :layout
        alias_method_chain :render_message, :layouts
      end
    end
  end
end

ActionMailer::Base.send :include, ActionMailer::Layouts