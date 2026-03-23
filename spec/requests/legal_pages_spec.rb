require "rails_helper"

RSpec.describe "Legal pages" do
  it "renders the terms page" do
    get terms_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Terms of Use")
  end

  it "renders the cookies policy page" do
    get cookies_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Cookie Policy")
    expect(response.body).to include("Reset my choice")
  end
end
