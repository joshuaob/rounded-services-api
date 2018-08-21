module RoundedServices
  module Entity
    describe JobListing do
      let(:a_job_listing) { described_class.new }
      
      it "responds to #inactive_at" do
        expect(a_job_listing).to respond_to(:inactive_at)
      end
    end
  end
end
