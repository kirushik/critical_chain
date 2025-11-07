module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      wait_for_jquery
      loop until finished_all_ajax_requests?
    end
  end

  def wait_for_jquery
    loop until page.evaluate_script("typeof jQuery !== 'undefined'")
    sleep 0.1
  end

  def finished_all_ajax_requests?
    sleep 0.05
    page.evaluate_script("typeof jQuery !== 'undefined' && jQuery.active === 0")
  end
end
