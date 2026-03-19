ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "spec_helper"
require "capybara/rspec"
require "selenium-webdriver"
require "rack/test"
require "socket"
require "active_support/testing/time_helpers"

Dir[File.join(__dir__, "support", "**", "*.rb")].sort.each { |file| require file }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => error
  abort error.to_s.strip
end

Capybara.app = Rails.application
Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }

windows_chrome_path = "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
js_system_tests_available = File.exist?(windows_chrome_path)

if js_system_tests_available
  begin
    probe_server = TCPServer.new("127.0.0.1", 0)
    probe_server.close
  rescue StandardError
    js_system_tests_available = false
  end
end

if js_system_tests_available
  Capybara.register_driver :windows_chrome_headless do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.binary = windows_chrome_path
    options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--window-size=1400,1400")

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.javascript_driver = :windows_chrome_headless
end

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Capybara::DSL, type: :system
  config.include Rails.application.routes.url_helpers
  config.include RequestSpecHelpers, type: :request
  config.include SystemAuthHelpers, type: :system
  config.include TestDataHelpers

  config.define_derived_metadata(file_path: %r{/spec/system/}) do |metadata|
    metadata[:type] = :system
  end

  config.define_derived_metadata(file_path: %r{/spec/requests/}) do |metadata|
    metadata[:type] = :request
  end

  config.before(:suite) do
    TestDatabaseHelpers.clean
  end

  config.before do
    TestDatabaseHelpers.clean
    ActionMailer::Base.deliveries.clear
  end

  config.after do
    travel_back
  rescue StandardError
    nil
  end

  config.before(type: :system) do
    Capybara.current_driver = :rack_test
  end

  config.before(type: :system, js: true) do
    skip "JavaScript browser driver is unavailable in this environment." unless js_system_tests_available

    Capybara.current_driver = :windows_chrome_headless
  end

  config.after(type: :system) do
    Capybara.use_default_driver
    Capybara.reset_sessions!
  end
end
