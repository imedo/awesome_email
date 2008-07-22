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
      
      def render_message_with_converted_entities(method_name, body)
        message = render_message_without_converted_entities(method_name, body)
        message =~ /<html/ ? convert_to_entities(message) : message
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