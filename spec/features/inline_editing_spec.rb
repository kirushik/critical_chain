require 'rails_helper'

feature "AdditionOfEstimationsAndItems", :type => :feature do
  let(:user) { FactoryGirl.create(:user_with_nonempty_estimations) }
  let(:estimation) { user.estimations.first }
  let(:estimation_item) { estimation.estimation_items.first }

  let(:title_field_id) { "\#estimation_item_#{estimation_item.id}_title" }
  let(:old_estimation_title) { estimation_item.title }
  let(:new_estimation_title) { 'Kapandlya' }

  let(:value_field_id) { "\#estimation_item_#{estimation_item.id}_value" }
  let(:old_estimation_value) { estimation_item.value }
  let(:new_estimation_value) { 7 }

  before(:each) do
    login_as user
    visit estimation_path(estimation)
  end

  scenario 'I can modify the estimation item title', :js do
    title_input = page.find("input#{title_field_id}")
    expect(title_input.value).to eq old_estimation_title

    title_input.set new_estimation_title
    title_input.native.send_keys(:return)

    wait_for_ajax
    expect(page.find("input#{title_field_id}").value).to eq new_estimation_title

    visit current_path
    expect(page.find("input#{title_field_id}").value).to eq new_estimation_title
  end

  scenario 'I can modify estimation item value', :js do
    value_input = page.find("input#{value_field_id}")
    expect(value_input.value).to eq old_estimation_value.to_s

    value_input.set new_estimation_value
    value_input.native.send_keys(:return)

    wait_for_ajax

    expect(page.find("input#{value_field_id}").value).to eq new_estimation_value.to_s
    expect(page).to have_text '7 + 7 = 14'

    visit current_path

    expect(page.find("input#{value_field_id}").value).to eq new_estimation_value.to_s
    expect(page).to have_text '7 + 7 = 14'
  end

  scenario 'AJAX-added items are editable', :js do
    fill_in 'estimation_item_value', with: new_estimation_value
    fill_in 'estimation_item_title', with: new_estimation_title
    click_button 'Add estimation item'

    wait_for_ajax

    new_item_id = estimation.reload.estimation_items.last.id

    expect(page).to have_css('input.editable.value', count: estimation.estimation_items.count)
    expect(page).to have_css('input.editable.title', count: estimation.estimation_items.count)
    expect(page).to have_css('input.editable.quantity', count: estimation.estimation_items.count)

    expect(page.evaluate_script("document.getElementById('estimation_item_#{new_item_id}_title').onblur != null"))
    expect(page.evaluate_script("document.getElementById('estimation_item_#{new_item_id}_value').onblur != null"))
    expect(page.evaluate_script("document.getElementById('estimation_item_#{new_item_id}_quantity').onblur != null"))
  end

  scenario 'I can mark estimation item as fixed', :js do
    find(:css, '.toggle-fixed').click

    expect(page).to have_text "#{old_estimation_value} + 0 = #{old_estimation_value}"
  end

  scenario 'I can set the number for a batch', :js do
    page.find('input.editable.quantity').set '4'
    page.find('input.editable.quantity').native.send_keys(:return)

    wait_for_ajax

    expect(page).to have_text "#{4*old_estimation_value} + #{2*old_estimation_value} = #{6*old_estimation_value}"
  end
end
