require "rails_helper"

RSpec.describe "Home Page", type: :system do
  it "displays the hero section" do
    visit root_path

    expect(page).to have_content("Darts Tournament")
    expect(page).to have_content("Manager")
    expect(page).to have_link("Create Tournament")
  end

  it "navigates to tournament creation page" do
    visit root_path
    click_link "Create Tournament", match: :first

    expect(page).to have_content("Create Tournament")
    expect(page).to have_current_path(new_tournament_path)
  end

  it "stimulus controller responds to user interaction", js: true do
    visit root_path

    find("input.rounded-lg", match: :first).set("World")
    click_button "Test Stimulus"

    expect(page).to have_content("Hello, World! Stimulus is working.")
  end
end
