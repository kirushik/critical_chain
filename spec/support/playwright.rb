require 'playwright'

module PlaywrightHelpers
  def page
    @playwright_page
  end

  def browser
    @playwright_browser
  end

  def context
    @playwright_context
  end

  # Visit a path (compatible with Capybara's visit method)
  def visit(path)
    # Build the full URL using Capybara server's settings
    unless path.start_with?('http')
      # Use the Capybara server instance
      host = @capybara_server.host
      port = @capybara_server.port
      path = "http://#{host}:#{port}#{path}"
    end

    page.goto(path)
    # Wait for Turbo and network to settle
    wait_for_turbo
  end

  # Wait for Turbo Drive and Turbo Frames to finish loading
  def wait_for_turbo
    page.evaluate(<<~JS)
      new Promise((resolve) => {
        // Wait for Turbo to be ready
        if (document.documentElement.hasAttribute('data-turbo-preview')) {
          document.addEventListener('turbo:load', () => resolve(), { once: true });
        } else {
          resolve();
        }
      });
    JS

    # Wait for any busy Turbo Frames
    page.wait_for_function(<<~JS, timeout: 5000)
      !document.querySelector('turbo-frame[busy]')
    JS
  rescue Playwright::TimeoutError
    # Turbo might not be present or frames might not exist, that's okay
  end

  # Wait for Stimulus controllers to be loaded and connected
  def wait_for_stimulus
    page.evaluate(<<~JS)
      new Promise((resolve) => {
        if (window.Stimulus) {
          resolve();
        } else {
          window.addEventListener('stimulus:load', () => resolve(), { once: true });
        }
      });
    JS
  rescue Playwright::TimeoutError
    # Stimulus might not be present, that's okay
  end

  # Accept a confirmation dialog (compatible with Capybara's accept_confirm)
  def accept_confirm(&block)
    page.once('dialog', ->(dialog) { dialog.accept })
    block.call
  end

  # Dismiss a confirmation dialog (compatible with Capybara's dismiss_confirm)
  def dismiss_confirm(&block)
    page.once('dialog', ->(dialog) { dialog.dismiss })
    block.call
  end

  # Take a screenshot on failure
  def save_screenshot(path)
    page.screenshot(path: path)
  end

  # Custom matchers for Playwright that mimic Capybara's API
  def have_text(text, **options)
    lambda do |locator_or_page|
      target = locator_or_page.is_a?(String) ? page.locator(locator_or_page) : locator_or_page
      begin
        if target.respond_to?(:text_content)
          target.wait_for(state: 'visible', timeout: (options[:wait] || 10) * 1000)
          target.text_content.include?(text)
        else
          # It's the page object
          page.get_by_text(text).wait_for(state: 'visible', timeout: (options[:wait] || 10) * 1000)
          true
        end
      rescue Playwright::TimeoutError
        false
      end
    end
  end

  def have_css(selector, **options)
    lambda do |_page|
      begin
        locator = page.locator(selector)
        if options[:text]
          locator = locator.filter(has_text: options[:text])
        end
        locator.wait_for(state: 'visible', timeout: (options[:wait] || 10) * 1000)
        true
      rescue Playwright::TimeoutError
        false
      end
    end
  end

  def have_content(text)
    have_text(text)
  end

  def have_no_text(text)
    lambda do |_page|
      begin
        page.get_by_text(text, exact: false).wait_for(state: 'hidden', timeout: 2000)
        true
      rescue Playwright::TimeoutError
        false
      end
    end
  end

  def have_no_css(selector)
    lambda do |_page|
      begin
        page.locator(selector).wait_for(state: 'hidden', timeout: 2000)
        true
      rescue Playwright::TimeoutError
        false
      end
    end
  end
end

RSpec.configure do |config|
  # Set up Playwright for :playwright tagged tests
  config.around(:each, :playwright) do |example|
    # Boot Capybara server (needed for Rails app to be accessible)
    # We create a session which will start the server
    @capybara_server = Capybara::Server.new(Rails.application).boot

    Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
      playwright.chromium.launch(headless: true, args: ['--disable-dev-shm-usage', '--no-sandbox']) do |browser|
        context = browser.new_context(
          viewport: { width: 1400, height: 1400 },
          ignoreHTTPSErrors: true
        )
        @playwright_page = context.new_page
        @playwright_context = context
        @playwright_browser = browser

        # Set default timeout
        @playwright_page.set_default_timeout(10_000) # 10 seconds
        @playwright_page.set_default_navigation_timeout(30_000) # 30 seconds

        # Include helper methods
        extend PlaywrightHelpers

        begin
          example.run
        rescue => e
          # Take screenshot on failure
          screenshot_path = "tmp/screenshots/#{example.full_description.gsub(/[^0-9A-Za-z]/, '_')}.png"
          FileUtils.mkdir_p('tmp/screenshots')
          @playwright_page.screenshot(path: screenshot_path) if @playwright_page
          puts "Screenshot saved to: #{screenshot_path}"
          raise e
        ensure
          context.close
        end
      end
    end
  end

  config.include PlaywrightHelpers, :playwright
end
