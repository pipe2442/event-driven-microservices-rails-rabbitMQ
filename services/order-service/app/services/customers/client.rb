module Customers
  class Client
    include HTTParty
    base_uri ENV.fetch("CUSTOMER_SERVICE_URL", "http://localhost:3001")

    def self.fetch_customer(public_id)
      response = get("/api/customers/#{public_id}")

      if response.success?
        response.parsed_response
      elsif response.code == 404
        nil
      else
        raise "Customer Service error: #{response.code}"
      end
    end
  end
end
