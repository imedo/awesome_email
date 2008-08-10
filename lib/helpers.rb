module AwesomeEmail
  module Helpers
    
    # helper methods for ActionView::Base
    module Views
      # prints the contents of a file to the page
      # default file_name is 'html-mail.css'
      def render_css_file(file_name = 'html-mail.css')
        file_name = "#{file_name}.css" unless file_name.end_with?('.css')
        relative_path = File.join('public', 'stylesheets', 'mails', file_name)
        files = Dir.glob(File.join(RAILS_ROOT, '**', relative_path))
        full_path = files.blank? ? File.join(RAILS_ROOT, relative_path) : files[0]
        File.read(full_path) rescue ''
      end
      
      # outputs style sheet information into the header of a webpage
      # to link the stylesheet absolute, we have to pass in the server_url like: "http://localhost" or "https://localhost:3001"
      def mail_header_styles(server_url, file_name)
        return '' if file_name.blank?
        %Q{<link rel="stylesheet" href="#{File.join(server_url, file_name)}" />\n<style type="text/css"><!-- #{render_css_file(file_name)} --></style>}
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