require "selenium-webdriver"

options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
driver = Selenium::WebDriver.for :firefox, options: options
driver.navigate.to "http://google.com"

element = driver.find_element(name: 'q')
element.send_keys "Hello WebDriver!"
element.submit

puts driver.title

driver.quit
