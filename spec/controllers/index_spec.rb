require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "#index" do
    # Make sure there are multiple users in the database,
    # and select one at random that will feature in the random scope
    # returned by the policy.
    let!(:user) { 3.times.map { User.create! }.sample }

    before do
      # Stub policy to return a random scope that could only result from here
      expect_any_instance_of(UserPolicy::Scope).
        to receive(:resolve).and_return(User.where(id: user.id))

      get :index
    end

    it "uses the Pundit scope" do
      unless response.status == 200
        body[:errors].each do |error|
          puts error[:meta][:exception]
          puts error[:meta][:backtrace]
        end
        fail "Expected 200 OK but was #{response.status}"
      end

      expect(body[:data].count).to eq 1
      expect(body.dig(:data, 0, :id)).to eq user.id.to_s
    end
  end
end
