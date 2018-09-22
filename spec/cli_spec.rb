# frozen_string_literal: true

RSpec.describe CensysWatch::CLI, :vcr do
  subject { CensysWatch::CLI }

  describe "#search" do
    it "should not raise any error" do
      params = ["search", '"deepMiner.min.js" AND location.country_code: US']
      subject.start params
    end
  end
end