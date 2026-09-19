# frozen_string_literal: true

RSpec.describe Yamshik::HTTP::CircuitBreaker do
  subject(:breaker) { described_class.new(failure_threshold: 2, reset_timeout: 30) }

  def fail_with(error = Yamshik::TimeoutError)
    breaker.call { raise error }
  rescue Yamshik::Error
    nil
  end

  it "starts closed and passes calls through" do
    expect(breaker.state).to eq(:closed)
    expect(breaker.call { 42 }).to eq(42)
  end

  it "opens after failure_threshold consecutive failures and fails fast" do
    2.times { fail_with }

    expect(breaker.state).to eq(:open)
    expect { breaker.call { 1 } }.to raise_error(Yamshik::CircuitOpenError)
  end

  it "resets the failure counter on success" do
    fail_with
    breaker.call { :ok }
    fail_with

    expect(breaker.state).to eq(:closed)
  end

  it "does not swallow the original error" do
    expect { breaker.call { raise Yamshik::TimeoutError, "boom" } }
      .to raise_error(Yamshik::TimeoutError, "boom")
  end

  context "with reset_timeout in the past" do
    subject(:breaker) { described_class.new(failure_threshold: 1, reset_timeout: 0) }

    it "half-opens after cooldown and closes on a successful trial" do
      fail_with
      sleep(0.001)

      expect(breaker.call { :recovered }).to eq(:recovered)
      expect(breaker.state).to eq(:closed)
    end

    it "re-opens when the trial call fails" do
      fail_with
      sleep(0.001)
      fail_with

      expect(breaker.state).to eq(:open)
    end
  end
end
