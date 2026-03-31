require "rails_helper"

RSpec.describe GamifiedXp do
  describe ".xp_needed_for_level" do
    it "makes the first levels much cheaper while staying scalable" do
      expect(described_class.xp_needed_for_level(1)).to eq(49)
      expect(described_class.xp_needed_for_level(2)).to eq(67)
      expect(described_class.xp_needed_for_level(5)).to eq(123)
      expect(described_class.xp_needed_for_level(10)).to eq(230)
      expect(described_class.xp_needed_for_level(100)).to eq(2991)
      expect(described_class.xp_needed_for_level(200)).to eq(6127)
    end
  end

  describe ".xp_gain_for" do
    it "keeps a level 1 streak-1 validation in the 20 to 30 XP target range" do
      expect(described_class.xp_gain_for(level: 1, streak: 1)).to eq(25)
      expect(described_class.xp_gain_for(level: 1, streak: 1)).to be_between(20, 30).inclusive
    end
  end

  describe ".debug_xp_progression" do
    it "prints a readable progression summary" do
      io = StringIO.new

      output = described_class.debug_xp_progression(io: io)

      expect(output).to include("Level | XP needed old->new")
      expect(output).to include("    1 |")
      expect(output).to include("  200 |")
      expect(io.string).to eq("#{output}\n")
    end
  end
end
