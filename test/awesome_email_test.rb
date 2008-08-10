# enable UTF-8 encoding
$KCODE = 'u'

require 'test/unit'
require 'rubygems'
gem 'actionmailer', '2.0.2'
gem 'actionpack', '2.0.2'
require 'action_mailer'
require 'action_view'
require 'awesome_email'

require 'test_helper'

ActionMailer::Base.delivery_method = :test

RAILS_ROOT = '/some/dir'


#################################################################

# Do some mocking, use Mocha here?
class SimpleMailer < ActionMailer::Base
  
  def test
    setup_multipart_mail
    layout 'test'
  end
  
  protected 

  def setup_multipart_mail
    headers       'Content-transfer-encoding' => '8bit'
    sent_on       Time.now
    content_type  'text/html'
  end

  def html_part?(method_name)
    true
  end

  def render_content_for_layout(method_name, template)
    'test inner content'
  end
  
  # mock rendering
  def render_layout_template(template, method_name, layout_path = File.join('layouts', 'mailers'))
    return template.render(:inline => "<html><body><h1>Fäncy</h1><p><%= yield %></p></body></html>")
  end
  
end

###############################################################

# test mailer
class MyMailer
  def render_message(method_name, body)
  end

  def parse_css_from_file(file_name)
    "h1 {font-size:140%}"
  end

  def mailer_name
    "my_mailer"
  end
  
  # include neccessary mixins
  include ActionMailer::AdvAttrAccessor
  include ActionMailer::ConvertEntities
  include ActionMailer::InlineStyles
  include ActionMailer::Layouts
end

MyMailer.send(:public, *MyMailer.protected_instance_methods)  
MyMailer.send(:public, *MyMailer.private_instance_methods)


###############################################################

# not so great actually, please do help improve this
class AwesomeEmailTest < Test::Unit::TestCase
  
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @css = "h1 {font-size:140%}"
    @mailer = MyMailer.new
  end
  
  
  #######################
  # inline styles tests #
  #######################
  
  def test_should_build_correct_find_css_file_name
    assert_equal "/some/dir/public/stylesheets/mails/test.css", @mailer.build_css_file_name("test")
  end
  
  def test_should_build_correct_file_name_from_set_css
    @mailer.css 'test'
    assert_equal '/some/dir/public/stylesheets/mails/test.css', @mailer.build_css_file_name_from_css_setting
  end
  
  def test_should_build_no_file_name_if_css_not_set
    assert_equal '', @mailer.build_css_file_name_from_css_setting
  end
  
  def test_should_not_change_html_if_no_styles_were_found
    html = build_html('', '')
    result = render_inline(html)
    assert_not_nil result
    assert_equal html, result
  end
  
  def test_should_add_style_information_found_in_css_file
    html = build_html('<h1>bla</h1>')
    result = render_inline(html)
    assert_not_nil result
    assert_not_equal html, result
    assert result =~ /<h1 style="font-size:/ 
  end
  
  def test_should_find_matching_rules
    rules = find_rules(build_html('', '<h1>bla</h1>'))
    assert rules.size > 0
  end
  
  def test_should_create_css_for_h1
    rules = find_rules(build_html('<h1>bla</h1>'))
    css = @mailer.css_for_rule(rules.first)
    assert_not_nil css
    assert_equal 'font-size:140%;', css
  end
  
  def test_should_cummulate_style_information
    html = build_html(%Q{<h1 id="oh-hai" class="green-thing" style="border-bottom:1px solid black">u haz a flavor</h1>})
    inlined = render_inline(html)
    assert inlined =~ /border-bottom/
  end
  
  ##########################
  # convert entities tests #
  ##########################

  def test_should_replace_entities
    expected = '&auml; &Auml;'
    result = @mailer.convert_to_entities('ä Ä')
    assert_equal expected, result
  end

  ################
  # layout tests #
  ################

  def test_should_extend_with_mailer_name
    template_name = 'some_mail'
    result = @mailer.extend_with_mailer_name(template_name)
    assert_equal "my_mailer/#{template_name}", result
  end
  
  # make sure the accessors are available
  def test_should_have_awesome_email_accessor_methods
    assert ActionMailer::Base.instance_methods.include?('css')
    assert ActionMailer::Base.instance_methods.include?('css=')
    assert ActionMailer::Base.instance_methods.include?('layout')
    assert ActionMailer::Base.instance_methods.include?('layout=')
  end
  
  # check for delivery errors
  def test_should_deliver
    SimpleMailer.deliver_test
    assert SimpleMailer.deliveries.size > 0
  end
  
  # test all of the awesomeness
  def test_should_render_layout_convert_entities_and_apply_css
    SimpleMailer.deliver_test
    assert SimpleMailer.deliveries.last.body =~ /<h1>F&auml;ncy<\/h1><p>test inner content<\/p>/
  end

end