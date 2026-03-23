require "rails_helper"

RSpec.describe "Mailer layouts", type: :view do
  describe "layouts/mailer" do
    it "wraps HTML email content" do
      render inline: "<p>Mail body</p>", layout: "layouts/mailer"

      expect(rendered).to include("<body>")
      expect(parsed_html).to have_text("Mail body")
    end
  end

  describe "layouts/mailer.text" do
    it "renders the plain text body" do
      view.lookup_context.formats = [:text]
      render inline: "Mail body", layout: "layouts/mailer"

      expect(rendered).to include("Mail body")
    end
  end
end
