module ActionMailer
  module InlineStyles
    module ClassMethods
      def initialize_csspool
        @css_pool_initialized ||= begin
          require 'hpricot'
          require 'csspool'

          ::CSS::SAC::GeneratedParser.send :include, ::CSS::SAC::Conditions
          
          true
        end
      end
    end
    
    module InstanceMethods
      
      def inline(html)
        self.class.initialize_csspool
        
        css_doc = parse_css_doc(build_css_file_name_from_css_setting)
        html_doc = parse_html_doc(html)
        render_inline(css_doc, html_doc)
      end
      
      def render_message_with_inline_styles(method_name, body)
        message = render_message_without_inline_styles(method_name, body)
        return message if @css.blank?
        inline(message)
      end
      
      protected
      
      def render_inline(css_doc, html_doc)
        css_doc.find_all_rules_matching(html_doc).each do |rule|
          inline_css = css_for_rule(rule)
          (html_doc/rule.selector.to_css).each{|e| e['style'] = inline_css + (e['style']||'') }
        end
        html_doc.to_s
      end
      
      def css_for_rule(rule)
        rule.properties.map do |key, value, important|
          build_css(key, value, important)
        end.join
      end
      
      def build_css(key, value, important)
        delimiter = (key == 'font-family') ? ', ' : ' '
        values = [value].flatten.join(delimiter)
        "#{key}:#{values}#{important ? ' !important' : ''};"
      end
      
      def parse_html_doc(html)
        Hpricot.parse(html)
      end
      
      def parse_css_doc(file_name)
        sac = CSS::SAC::Parser.new
        sac.parse(read_css_from_file(file_name))
      end
      
      def read_css_from_file(file_name)
        File.exists?(file_name) ? File.read(file_name) : ''
      end
      
      def build_css_file_name_from_css_setting
        @css.blank? ? '' : build_css_file_name(@css)
      end
      
      def build_css_file_name(css_name)
        file_name = css_name =~ /\.css$/ ? css_name : "#{css_name}.css"
        full_path_to_file = Dir.glob(File.join(RAILS_ROOT, 'public', 'stylesheets', '**', file_name))[0] || File.join(RAILS_ROOT, 'public', 'stylesheets', 'mails', file_name)
        #Lets try to find the file in case it isn't in the public/stylesheets directory
        unless File.exists?(full_path_to_file)
          full_path_to_file = (File.join(RAILS_ROOT, 'public', file_name))
        end

        full_path_to_file
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      
      receiver.class_eval do
        adv_attr_accessor :css
        alias_method_chain :render_message, :inline_styles
      end
    end
  end
end

ActionMailer::Base.send :include, ActionMailer::InlineStyles