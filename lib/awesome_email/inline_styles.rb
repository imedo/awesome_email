# coding: utf-8
$KCODE = 'u' unless RUBY_VERSION >= '1.9'

require 'rubygems'

gem 'nokogiri', '>= 1.3.3'
gem 'csspool', '>= 2.0.0'

require 'nokogiri'
require 'csspool'

module ActionMailer
  module InlineStyles
    
    STYLE_ATTR = (RUBY_VERSION >= '1.9') ? :style : 'style'
    
    module ClassMethods
      # none
    end
    
    module InstanceMethods
      
      def inline(html)
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
          
          css_doc.rule_sets.each do |rule_set|
            inline_css = css_for_rule(rule_set)
            #Nokogiri libs cant do a:.* selectors
            rule_set.selectors.collect(&:to_s).reject{|i| i =~ /^a:.+/}.each do |selector|
              html_doc.css(selector).each do |element|
                element[STYLE_ATTR] = [inline_css, element[STYLE_ATTR]].compact.join('').strip
                element[STYLE_ATTR] << ';' unless element[STYLE_ATTR] =~ /;$/
              end
            end
          end
          html_doc.to_html
        end
        
        def css_for_rule(rule_set)
          rule_set.declarations.map do |declaration|
            declaration.to_s.strip
          end.join
        end
        
        def parse_html_doc(html)
          html_doc = Nokogiri::HTML.parse(html)
        end
        
        def parse_css_doc(file_name)
          css_doc = CSSPool.CSS(read_css_from_file(file_name))
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
      receiver.class_eval do
        extend ClassMethods
        include InstanceMethods
        
        adv_attr_accessor :css
        alias_method_chain :render_message, :inline_styles
      end
    end
    
  end
end

ActionMailer::Base.send :include, ActionMailer::InlineStyles
