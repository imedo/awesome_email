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
        render_content method_name, template
        method_name_with_extension = add_extension(extend_with_mailer_name(method_name))
        render_layout_template template, method_name_with_extension
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
        template.render(:file => add_extension(file_name))
      end
    
      # finds the layout file and renders it, if the file is not found an exception is raised
      # default path for all mailer layouts is layouts/mailers below app/views/
      # you can pass in another layout path as 3rd arguments
      def render_layout_template(template, method_name, layout_path = File.join('layouts', 'mailers'))
        extension_parts = method_name.split('.')[1..-1]
        while !extension_parts.blank?
          file_name = File.join(layout_path, ([@layout.to_s] + extension_parts).join('.'))
          return render_layout(file_name, template) if template_exists?(file_name)
          extension_parts.shift
        end
        # nothing found, complain
        raise "Layout '#{@layout}' not found"
      end
      
      def render_layout(file_name, template)
        template.render(file_name)
      end
      
      # check if a the given view exists within the app/views folder
      # make sure only allowed extensions are found
      def template_exists?(file_name)
        return true if file_exists?(file_name)
        
        extensions = ActionMailer::Base.template_extensions
        extensions.each do |extension|
          [content_type.gsub('/', '.'), nil].each do |middle|
            full_name = [filename, middle, extension].compact.join('.')
            return true if file_exists?(full_name)
          end
        end
        false
      end
      
      def file_exists?(filename)
        ActionController::Base.view_paths.each do |path|
          return true if File.exist?(File.join(path, filename))
        end
        false
      end
      
      def add_extension(filename)
        extensions = ActionMailer::Base.template_extensions
        extensions.each do |extension|
          [content_type.gsub('/', '.'), nil].each do |middle|
            full_name = [filename, middle, extension].compact.join('.')
            return full_name if file_exists?(full_name)
          end
        end
        filename
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
