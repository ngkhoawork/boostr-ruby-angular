module Helpers
  def ui_select(value)
    within '.ui-select-match' do
      find('span.btn').click()
    end
    find('.ui-select-search').set(value)
    find('.ui-select-choices-row-inner').click()
  end
end