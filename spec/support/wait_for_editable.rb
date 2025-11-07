module WaitForEditable
  def visit(*args)
    super
    # Wait for jQuery and x-editable to be loaded after page visit
    wait_for_editable_initialization if respond_to?(:page) && page.driver.is_a?(Capybara::Apparition::Driver)
  end

  def wait_for_editable_initialization
    # Wait for jQuery and x-editable to be loaded
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until page.evaluate_script("typeof jQuery !== 'undefined' && typeof jQuery.fn.editable !== 'undefined'")
    end
    # Give a bit more time for editables to initialize
    sleep 0.3
  rescue Timeout::Error, Capybara::Apparition::JavascriptError
    # If jQuery or editable isn't available, that's okay - not all pages have it
  end

  def wait_for_editable
    wait_for_editable_initialization
  end
end

