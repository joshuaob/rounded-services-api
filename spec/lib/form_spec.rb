module RoundedServices
  module Form
    describe JobListing do
      describe "#new" do
        it "is initialized correctly" do
          attributes_hash = attributes_for(:job_listing)

          attributes_hash[:employer] = "Rounded Services"
          attributes_hash[:account] = create(:account)
          attributes_hash[:location] = "Leeds, UK"
          attributes_hash[:stripe_token] = "123"

          form = described_class.new(attributes_hash: attributes_hash)

          expect(form.keywords).to eq(attributes_hash[:keywords])
          expect(form.title).to eq(attributes_hash[:title])
          expect(form.email).to eq(attributes_hash[:email])
          expect(form.url).to eq(attributes_hash[:url])
          expect(form.job_type).to eq(attributes_hash[:job_type])
          expect(form.commute_type).to eq(attributes_hash[:commute_type])
          expect(form.salary).to eq(attributes_hash[:salary])
          expect(form.employer).to eq(attributes_hash[:employer])
          expect(form.account).to eq(attributes_hash[:account])
          expect(form.location).to eq(attributes_hash[:location])
          expect(form.stripe_token).to eq(attributes_hash[:stripe_token])
        end
      end

      describe "#to_hash" do
        it "ignores nil attributes" do
          attributes_hash = attributes_for(:job_listing)
          form = described_class.new(attributes_hash: attributes_hash)

          hash = form.to_hash

          expect(hash["keywords"]).to eq(attributes_hash[:keywords])
          expect(hash["title"]).to eq(attributes_hash[:title])
          expect(hash["email"]).to eq(attributes_hash[:email])
          expect(hash["url"]).to eq(attributes_hash[:url])
          expect(hash["job_type"]).to eq(attributes_hash[:job_type])
          expect(hash["commute_type"]).to eq(attributes_hash[:commute_type])
          expect(hash["salary"]).to eq(attributes_hash[:salary])
          expect(hash.keys.include?("employer")).to eq(false)
          expect(hash.keys.include?("account")).to eq(false)
          expect(hash.keys.include?("location")).to eq(false)
          expect(hash.keys.include?("stripe_token")).to eq(false)
        end
      end
    end
  end
end


# self.keywords = attributes_hash[:keywords]
# self.url = attributes_hash[:url].downcase
# self.email = attributes_hash[:email].downcase
# self.title = attributes_hash[:title].downcase
# self.job_type = attributes_hash[:job_type].downcase
# self.commute_type = attributes_hash[:commute_type].downcase
# self.salary = attributes_hash[:salary].downcase
# self.employer = attributes_hash[:employer]
# self.account = attributes_hash[:account]
# self.location = attributes_hash[:location]
# self.stripe_token = attributes_hash[:stripe_token] || nil
