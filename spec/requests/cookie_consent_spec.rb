require "rails_helper"

RSpec.describe "Cookie consent" do
  it "stores an essential consent level for 6 months" do
    post cookie_consent_path(level: "essential")

    expect(last_response.status).to eq(303)
    expect(rack_mock_session.cookie_jar["cookie_consent"]).to eq("essential")
  end

  it "stores an all consent level for 6 months" do
    post cookie_consent_path(level: "all")

    expect(last_response.status).to eq(303)
    expect(rack_mock_session.cookie_jar["cookie_consent"]).to eq("all")
  end

  it "defaults to essential when level is invalid" do
    post cookie_consent_path(level: "nope")

    expect(last_response.status).to eq(303)
    expect(rack_mock_session.cookie_jar["cookie_consent"]).to eq("essential")
  end

  it "removes the stored consent level" do
    post cookie_consent_path(level: "all")
    expect(rack_mock_session.cookie_jar["cookie_consent"]).to eq("all")

    delete cookie_consent_path

    expect(last_response.status).to eq(303)
    expect(rack_mock_session.cookie_jar["cookie_consent"]).to be_blank
  end
end
