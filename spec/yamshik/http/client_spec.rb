# frozen_string_literal: true

RSpec.describe Yamshik::HTTP::Client do
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) do
    Faraday.new(url: "https://api.example.test") do |faraday|
      faraday.request :json
      faraday.adapter :test, stubs
    end
  end
  let(:sleeper) { ->(_seconds) {} }
  let(:client) { described_class.new(base_url: "https://api.example.test", connection:, sleeper:) }

  describe "successful responses" do
    it "returns 2xx responses" do
      stubs.get("/orders") { [200, { "Content-Type" => "application/json" }, '{"ok":true}'] }

      response = client.get("/orders")

      expect(response.status).to eq(200)
    end

    it "returns business-level 4xx to the caller" do
      stubs.post("/orders") { [422, {}, '{"error":"bad"}'] }

      expect(client.post("/orders", body: {}).status).to eq(422)
    end
  end

  describe "status mapping" do
    it "raises AuthenticationError on 401 and 403" do
      stubs.get("/a") { [401, {}, ""] }
      stubs.get("/b") { [403, {}, ""] }

      expect { client.get("/a") }.to raise_error(Yamshik::AuthenticationError)
      expect { client.get("/b") }.to raise_error(Yamshik::AuthenticationError)
    end

    it "raises CarrierUnavailableError on 5xx after retries" do
      stubs.get("/down") { [500, {}, ""] }

      expect { client.get("/down") }.to raise_error(Yamshik::CarrierUnavailableError, "carrier responded 500")
    end

    it "raises RateLimitedError with retry_after on exhausted 429" do
      stubs.get("/limited") { [429, { "Retry-After" => "30" }, ""] }

      expect { client.get("/limited") }
        .to raise_error(Yamshik::RateLimitedError) { |e| expect(e.retry_after).to eq(30.0) }
    end
  end

  describe "retries" do
    it "retries idempotent requests on 5xx and succeeds" do
      attempts = 0
      stubs.get("/flaky") do
        attempts += 1
        attempts < 3 ? [500, {}, ""] : [200, {}, '{"ok":true}']
      end

      expect(client.get("/flaky").status).to eq(200)
      expect(attempts).to eq(3)
    end

    it "does not retry non-idempotent POST on ambiguous failures" do
      attempts = 0
      stubs.post("/orders") do
        attempts += 1
        [500, {}, ""]
      end

      expect { client.post("/orders", body: {}) }.to raise_error(Yamshik::CarrierUnavailableError)
      expect(attempts).to eq(1)
    end

    it "retries non-idempotent POST when the request definitely did not reach the server" do
      attempts = 0
      stubs.post("/orders") do
        attempts += 1
        raise Faraday::ConnectionFailed, "refused" if attempts == 1

        [200, {}, '{"ok":true}']
      end

      expect(client.post("/orders", body: {}).status).to eq(200)
      expect(attempts).to eq(2)
    end

    it "retries idempotent POST on ambiguous failures" do
      attempts = 0
      stubs.post("/orders") do
        attempts += 1
        raise Faraday::TimeoutError if attempts == 1

        [200, {}, '{"ok":true}']
      end

      expect(client.post("/orders", body: {}, idempotent: true).status).to eq(200)
    end

    it "gives up after max_retries" do
      client = described_class.new(base_url: "https://api.example.test", connection:, sleeper:, max_retries: 1)
      attempts = 0
      stubs.get("/always-down") do
        attempts += 1
        [503, {}, ""]
      end

      expect { client.get("/always-down") }.to raise_error(Yamshik::CarrierUnavailableError)
      expect(attempts).to eq(2)
    end
  end

  describe "faraday error mapping" do
    it "maps connection failures to ConnectionError" do
      stubs.get("/x") { raise Faraday::ConnectionFailed, "refused" }

      expect { client.get("/x") }.to raise_error(Yamshik::ConnectionError, "refused")
    end

    it "maps timeouts to TimeoutError" do
      stubs.get("/x") { raise Faraday::TimeoutError }

      expect { client.get("/x") }.to raise_error(Yamshik::TimeoutError)
    end
  end

  describe "circuit breaker integration" do
    it "fails fast with CircuitOpenError when the breaker is open" do
      breaker = Yamshik::HTTP::CircuitBreaker.new(failure_threshold: 1, reset_timeout: 60)
      client = described_class.new(base_url: "https://api.example.test", connection:, sleeper:, breaker:,
                                   max_retries: 0)
      stubs.get("/x") { raise Faraday::ConnectionFailed, "refused" }

      expect { client.get("/x") }.to raise_error(Yamshik::ConnectionError)
      expect { client.get("/x") }.to raise_error(Yamshik::CircuitOpenError)
    end
  end
end
