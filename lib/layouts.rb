module ActionMailer
  module Layouts
    module ClassMethods
      # none
    end
    
    module InstanceMethods
      
      # render with layout if it is set through the "layout" method and the a corresponding file is found 
      def render_message_with_layouts(method_name, body)
        return render_message_without_layouts(method_name, body) if @layout.blank?
        # template was set
        template = initialize_template_class body
        file_name = extend_with_mailer_name(method_name)
        # render template for called action
        template.instance_variable_set(:@content_for_layout, template.render(:file => file_name))
        extension_parts = method_name.split('.')[1..-1]
        render_template_for_extension_parts template, extension_parts
      end
      
    protected
      # finds the layout file and renders it, if the file is not found an exception is raised
      # default path for all mailer layouts is layouts/mailers below app/views/
      # you can pass in another layout path as 3rd arguments
      def render_template_for_extension_parts(template, extension_parts, layout_path = File.join("layouts", "mailers"))
        while !extension_parts.blank?
          file_name = File.join(layout_path, ([@layout.to_s] + extension_parts).join('.'))
          return template.render(file_name) if template.file_exists?(file_name)
          extension_parts.shift
        end
        # nothing found, complain
        raise "Layout #{@layout} not found"
      end
      
      def extend_with_mailer_name(template_name)
        template_name =~ /\// ? template_name : File.join(mailer_name, template_name)
      end
    end
    
    # create "layout" method to define the layout name
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