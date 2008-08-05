require File.join(File.dirname(__FILE__), 'layouts.rb')
require File.join(File.dirname(__FILE__), 'inline_styles.rb')
require File.join(File.dirname(__FILE__), 'convert_entities.rb')

module AwesomeEmail
  module Helpers
    
    # helper methods for ActionView::Base
    module Views
      # prints the contents of a file to the page
      def render_css_file(file_name)
        File.read(File.join(RAILS_ROOT, "public", file_name)) rescue ""
      end
      
      # outputs style sheet information into the header of a webpage
      # to link the stylesheet absolute, we have to pass in the server_url like: "http://localhost" or "https://localhost:3001"
      def mail_header_styles(server_url, file)
        %Q{<link rel="stylesheet" href="#{File.join(server_url, file)}" />\n<style type="text/css"><!-- #{render_css_file(file)} --></style>}
      end
    end
    
    # helper methods für ActionMailer::Base
    module Mailer
      protected 
      # sets a few variables that ensure good delivery of the mail
      def setup_multipart_mail
        headers       'Content-transfer-encoding' => '8bit'
        sent_on       Time.now
        content_type  'text/html'
      end
    end

  end
end

ActionView::Base.send(:include, AwesomeEmail::Helpers::Views)
ActionMailer::Base.send(:include, AwesomeEmail::Helpers::Mailer)