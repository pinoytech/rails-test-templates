require 'rails_helper'
require_relative '../support/login_form'
require_relative '../support/new_achievement_form'

# feature is an alias for describe
feature 'Create Achievement' do
  let(:new_achievement_form) { NewAchievementForm.new }
  let(:user) { FactoryGirl.create(:user) }
  let(:login_form) { LoginForm.new }

  # background is an alias of before
  background do
    login_form.visit_page.login_as(user)
  end

  # scenario is an alias of it
  scenario 'create new achievement with valid data' do
    new_achievement_form.visit_page.fill_in_with(
      title: 'Read a book'
    ).submit

    expect(page).to have_content('Achievement has been created')
    expect(Achievement.last.title).to eq('Read a book')
  end

  scenario 'cannot create new achievement with invalid data' do
    new_achievement_form.visit_page.submit
    expect(page).to have_content("can't be blank")
  end
end