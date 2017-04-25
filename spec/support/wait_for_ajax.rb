require 'timeout'

module WaitForAjax
  def wait_for_ajax(wait_time = 0.1)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        sleep wait_time
        break if finished_all_ajax_requests?
      end
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end
