require "rails_helper"

RSpec.describe "Legal pages" do
  it "renders the terms page" do
    get terms_path

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Terms of Use")
  end

  it "renders the cookies policy page" do
    get cookies_path

    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Cookie Policy")
    expect(last_response.body).to include("Reset my choice")
  end
end
