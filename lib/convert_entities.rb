module ActionMailer
  module ConvertEntities
    UMLAUTS = { 'ä' => '&auml;', 'ö' => '&ouml;', 'ü' => '&uuml;', 'Ä' => '&Auml;', 'Ö' => '&Ouml;', 'Ü' => '&Uuml;', 'ß' => '&szlig;' }
    
    module ClassMethods
      # none
    end
    
    module InstanceMethods
      # replace all umlauts
      def convert_to_entities(text)
        text.gsub(/[#{UMLAUTS.keys.join}]/) { |match| UMLAUTS[match] }
      end
      
      # convert entities only when rendering html
      def render_message_with_converted_entities(method_name, body)
        message = render_message_without_converted_entities(method_name, body)
        html_part?(method_name) ? convert_to_entities(message) : message
      end
      
      # check if the we are colling
      def html_part?(method_name)
        method_name.gsub(".", "/") =~ /#{Mime::EXTENSION_LOOKUP['html']}/ 
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