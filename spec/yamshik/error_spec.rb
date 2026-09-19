# frozen_string_literal: true

RSpec.describe Yamshik::Error do
  describe "hierarchy" do
    it "keeps all infrastructural errors under Yamshik::Error" do
      expect(Yamshik::TimeoutError.ancestors).to include(described_class)
      expect(Yamshik::ConnectionError.ancestors).to include(described_class)
      expect(Yamshik::AuthenticationError.ancestors).to include(described_class)
      expect(Yamshik::InvalidResponseError.ancestors).to include(described_class)
      expect(Yamshik::RateLimitedError.ancestors).to include(described_class)
      expect(described_class.ancestors).to include(StandardError)
    end
  end

  describe Yamshik::RateLimitedError do
    it "carries retry_after" do
      error = described_class.new("slow down", retry_after: 30)

      expect(error.message).to eq("slow down")
      expect(error.retry_after).to eq(30)
    end

    it "defaults retry_after to nil" do
      expect(described_class.new.retry_after).to be_nil
    end
  end
end
