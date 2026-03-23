require "rails_helper"

RSpec.describe "Cookie consent" do
  it "stores an essential consent level for 6 months" do
    post cookie_consent_path(level: "essential")

    expect(response).to have_http_status(:see_other)
    expect(cookies["cookie_consent"]).to eq("essential")
  end

  it "stores an all consent level for 6 months" do
    post cookie_consent_path(level: "all")

    expect(response).to have_http_status(:see_other)
    expect(cookies["cookie_consent"]).to eq("all")
  end

  it "defaults to essential when level is invalid" do
    post cookie_consent_path(level: "nope")

    expect(response).to have_http_status(:see_other)
    expect(cookies["cookie_consent"]).to eq("essential")
  end

  it "removes the stored consent level" do
    post cookie_consent_path(level: "all")
    expect(cookies["cookie_consent"]).to eq("all")

    delete cookie_consent_path

    expect(response).to have_http_status(:see_other)
    expect(cookies["cookie_consent"]).to be_blank
  end
end
