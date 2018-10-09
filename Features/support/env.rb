#encoding: UTF-8

require 'cucumber'
require 'rspec'
require 'selenium-webdriver'
require 'rest-client'
require 'capybara'
require 'capybara/dsl'
require 'oci8'
require 'time'
require 'timeout'
require 'rubygems'
# require 'os'
require 'json'

# require 'json/pure'

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.javascript_driver =:selenium
Capybara.default_selector =:css
Capybara.default_max_wait_time = 7
Capybara.ignore_hidden_elements = false
Capybara.exact = true
Capybara.app_host ='http://10.2.222.40:4000/treeview'
World(Capybara::DSL)


ENV['NO_PROXY'] = ENV['no_proxy'] = '127.0.0.1,.zfu.zb,10.*'
RestClient.proxy = ENV['no_proxy']

# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE # SSL validationı kapat

# if OS.windows?
#   Capybara.register_driver :selenium do |app|
#
#     Capybara::Selenium::Driver.new(app,
#                                    browser: :chrome,
#                                    desired_capabilities: {
#                                        'chromeOptions' => {
#                                            'useAutomationExtension' => false,
#                                            'forceDevToolsScreenshot' => true,
#                                            'args' => ['--disable-web-security', '--start-maximized', '--disable-infobars']
#                                        }
#                                    }
#
#     )
#
#   end
# else
#
#   require 'headless'
#   ENV['NO_PROXY'] = ENV['no_proxy'] = '127.0.0.1,.zfu.zb,10.*'
#   RestClient.proxy = ENV['no_proxy']
#
#
#   Capybara.register_driver :chrome do |app|
#     Capybara::Selenium::Driver.new(app, :browser => :chrome, :switches => %w[--window-size=1920,1080 --ignore-certificate-errors --headless --disable-gpu no-sandbox --disable-extensions --disable-web-security --allow-running-insecure-content --user-data-dir=c:/tmpcansin/chrome] )
#   end
#
#   Capybara.default_driver = :chrome
#   Capybara.javascript_driver = :chrome
#   headless = Headless.new
#   headless.start
#
# end




def convert_turkish_characters str
  replacements = [ ["Ş", "S"], ["ş", "s"],["Ğ", "G"],["ğ", "g"],["Ö", "O"],["ö", "o"],["Ü", "U"],["ü", "u"],["Ç", "C"],["ç", "c"], ["İ", "I"], ["ı", "i"] ]
  replacements.each {|replacement| str.gsub!(replacement[0], replacement[1])}
  return str
end


def clear_special str
  return str.gsub(/[^0-9A-Za-z]/, '')
end

def turkish_upcase str
  new_str = String.new
  str.chars.each { |x|
    case
    when 'ö'
      chr = 'Ö'
    when 'ü'
      chr = 'Ü'
    when 'i'
      chr = 'İ'
    when 'ı'
      chr = 'I'
    when 'ç'
      chr = 'Ç'
    when 'ş'
      chr = 'Ş'
    when 'ğ'
      chr = 'Ğ'
    else
      chr = x.upcase
    end
    new_str += chr
  }
  return new_str
end



$environment = 'qafa'

if $environment == 'uat'

  $database={
      "user"     => "sorgu",
      "password" => "sorgu1",
      "url"      => "10.11.208.167:1521/KULKABUL"
  }
elsif $environment == 'qa'

  $database={
      "user"     => "finarttest",
      "password" => "fin1art2test3",
      "url"      => "10.1.21.27:1536/TEST"
  }
elsif $environment == 'qafa'

  $database={
      "user"     => "sorgu",
      "password" => "sorgu1",
      "url"      => "10.11.208.129:1521/fadbtEST"
  }
elsif $environment == 'dev'
  $database={
      "user"     => "finartytl",
      "password" => "f2n6rtytl",
      "url"      => "10.1.21.26:1526/O10G"
  }
end

# puts $database["user"] + "|" + $database["password"] + "|" + $database["url"]

$db_connection = OCI8.new($database["user"],$database["password"],$database["url"])

$delete_enabled = true
$no_delete = true



# $screenshot_counter = 0
# After do |scenario|
#   $screenshot_counter += 1
#   take_screenshot(scenario)
# end


def take_screenshot(scenario)
  if scenario.failed?
    scenario_name = "#{(convert_turkish_characters scenario.name)}"
    scenario_name= scenario_name.split(" ").join('-').delete(',')
    puts scenario_name
    time = Time.now.strftime("%H.%M-%m.%d.%Y")
    time=time.to_s
    page.save_screenshot(File.absolute_path("features/screenshots/FAIL-#{time}-count-#{$screenshot_counter}-#{scenario_name[0..50]}.png"))
  end
end
