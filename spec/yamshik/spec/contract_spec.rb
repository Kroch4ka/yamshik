# frozen_string_literal: true

require "yamshik/spec/contract"

# The reference adapter runs the contract suite in the core's CI:
# if Fake fails it, the suite itself is broken, not the adapters.
RSpec.describe Yamshik::Spec::Contract do
  it_behaves_like "a yamshik carrier" do
    let(:carrier) { Yamshik::Adapters::Fake.new }
    let(:valid_parcel) { build_valid_parcel }
  end
end
