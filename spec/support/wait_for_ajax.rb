module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until turbo_finished?
      sleep 0.1
    end
  end

  def turbo_finished?
    # Checks for Turbo Drive, Turbo Frames, and Turbo Streams
    page.evaluate_script(<<~JS)
      (typeof Turbo === 'undefined') ||
      (
        !document.documentElement.hasAttribute('data-turbo-preview') &&
        document.querySelectorAll('[data-turbo-frame].busy').length === 0 &&
        !document.body.hasAttribute('data-turbo-stream-working')
      )
    JS
  end
end
