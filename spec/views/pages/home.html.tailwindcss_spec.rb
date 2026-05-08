require 'rails_helper'

RSpec.describe "pages/home", type: :view do
  it "renders the home page" do
    render
    expect(rendered).to have_selector("h1", text: "Darts Tournament")
  end
end
