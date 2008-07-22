module AwesomeEmail
  module Helper

    protected 
    def setup_multipart_mail
      headers       'Content-transfer-encoding'=>'8bit'
      sent_on       Time.now
      content_type  'text/html'
    end

  end
end
