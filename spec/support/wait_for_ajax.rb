module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished?
    end
    # Small delay to ensure DOM updates complete after async operations
    sleep 0.05
  end

  def finished?
    # Checks for:
    # 1. Turbo Drive, Turbo Frames, and Turbo Streams
    # 2. Pending fetch requests (vanilla JS AJAX)
    page.evaluate_script(<<~JS)
      (
        // Turbo check
        (typeof Turbo === 'undefined') ||
        (
          !document.documentElement.hasAttribute('data-turbo-preview') &&
          document.querySelectorAll('[data-turbo-frame].busy').length === 0 &&
          !document.body.hasAttribute('data-turbo-stream-working')
        )
      ) &&
      // Fetch requests check
      (typeof window.pendingFetchCount === 'undefined' || window.pendingFetchCount === 0)
    JS
  end
end
