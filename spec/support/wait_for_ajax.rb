module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    sleep 0.05
    # Check if Turbo is idle (no pending requests)
    page.evaluate_script("typeof Turbo === 'undefined' || !document.documentElement.hasAttribute('data-turbo-preview')")
  end
end
