require 'hpricot'
require 'csspool'

CSS::SAC::GeneratedParser.send :include, CSS::SAC::Conditions

module ActionMailer
  module InlineStyles
    module ClassMethods
      
    end
    
    module InstanceMethods
      
      # parse the html and add inline styling
      def inline(html, css)
        sac = CSS::SAC::Parser.new 
        css_doc = sac.parse(File.read("#{RAILS_ROOT}/public/stylesheets/mails/#{css}.css"))
        html_doc = Hpricot.parse(html)
        css_doc.find_all_rules_matching(html_doc).each do |rule|
          inline_css = rule.properties.map { |key,value,important|
                      join_val = ('font-family' == key) ? ', ' : ' '
                      values = [value].flatten.join(join_val)
                      "#{key}:#{values}#{important ? ' !important' : ''};"
                    }.join
          (html_doc/rule.selector.to_css).set('style', inline_css)
        end
        html_doc.to_s
      end
      
      def render_message_with_inline_styles(method_name, body)
        message = render_message_without_inline_styles(method_name, body)
        return message if @css.blank?
        
        inline(message, @css)
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