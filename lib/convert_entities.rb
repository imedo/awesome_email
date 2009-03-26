$KCODE = 'u'

module ActionMailer
  module ConvertEntities
    # Add more if replacements you need
    UMLAUTS = { 'ä' => '&auml;', 'ö' => '&ouml;', 'ü' => '&uuml;', 'Ä' => '&Auml;', 'Ö' => '&Ouml;', 'Ü' => '&Uuml;', 'ß' => '&szlig;' }
    
    module ClassMethods
      # none
    end
    
    module InstanceMethods
      # Replace all umlauts
      # Add more if replacements you need them
      def convert_to_entities(text)
        text.gsub(/[#{UMLAUTS.keys.join}]/u) { |match| UMLAUTS[match] }
      end
      
      # Convert entities only when rendering html
      def render_message_with_converted_entities(method_name, body)
        message = render_message_without_converted_entities(method_name, body)
        html_part?(method_name) ? convert_to_entities(message) : message
      end
      
      # Check if the part we are rendering is html
      def html_part?(method_name)
        method_name.to_s.gsub(".", "/") =~ /#{Mime::EXTENSION_LOOKUP['html']}/ 
      end
    end
    
    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
      
      receiver.class_eval do
        alias_method_chain :render_message, :converted_entities
      end
    end
  end
end

ActionMailer::Base.send :include, ActionMailer::ConvertEntities
