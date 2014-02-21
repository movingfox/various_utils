# This uses Ruby's sleep, so it's somewhat imprecise - but should do the
# job for you. Also, execute is called for everything so that's why it's
# sub-second waiting. The intermediate steps - wait until ready, check field,
# focus, enter text - each pause.
# Put it in your features/support directory.
# Then, in a step definition, call: set_speed(:slow) or: set_speed(:medium).
# To reset, call: set_speed(:fast)

require 'selenium-webdriver'
module ::Selenium::WebDriver::Firefox
  class Bridge
    attr_accessor :speed

    def execute(*args)
      result = raw_execute(*args)['value']
      case speed
        when :slow
          sleep 0.3
        when :medium
          sleep 0.1
      end
      result
    end
  end
end

def set_speed(speed)
  begin
    page.driver.browser.send(:bridge).speed=speed
  rescue
  end
end
