module ActionMailer
  module Layouts
    module ClassMethods
      # none
    end
    
    module InstanceMethods
      
      # render with layout, if it is set through the "layout" accessor method and a corresponding file is found 
      def render_message_with_layouts(method_name, body)
        return render_message_without_layouts(method_name, body) if @layout.blank?
        # template was set, now render with layout
        template = initialize_template_class body
        template = render_content method_name, template
        render_layout_template template, method_name
      end
      
    protected
      # tries to find a matching template and renders the inner content back to the template
      def render_content(method_name, template)
        template.instance_variable_set(:@content_for_layout, render_content_for_layout(method_name, template))
        template
      end
      
      # builds the filename from the method_name, then renders the inner content
      def render_content_for_layout(method_name, template)
        file_name = extend_with_mailer_name(method_name)
        template.render(:file => file_name)
      end
    
      # finds the layout file and renders it, if the file is not found an exception is raised
      # default path for all mailer layouts is layouts/mailers below app/views/
      # you can pass in another layout path as 3rd arguments
      def render_layout_template(template, method_name, layout_path = File.join('layouts', 'mailers'))
        extension_parts = method_name.to_s.split('.')[1..-1]
        while !extension_parts.blank?
          file_name = File.join(layout_path, ([@layout.to_s] + extension_parts).join('.'))
          return render_layout(file_name, template) if template_exists?(file_name)
          extension_parts.shift
        end
        # nothing found, complain
        raise "Layout '#{@layout}' not found"
      end
      
      def render_layout(file_name, template)
        template.render(:file => file_name)
      end
      
      # check if a the given view exists within the app/views folder
      def template_exists?(file_name)
        full_path = File.join(RAILS_ROOT, '**', 'views', file_name)
        files = Dir.glob(full_path)
        !files.blank?
      end
      
      def extend_with_mailer_name(template_name)
        template_name.to_s =~ /\// ? template_name : File.join(mailer_name, template_name)
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
