module Customers
  class Client
    def initialize(http: HTTParty, base_url: ENV.fetch("CUSTOMER_SERVICE_URL", "http://localhost:3001"))
      @http = http
      @base_url = base_url
    end

    def fetch_customer(public_id)
      response = @http.get("#{@base_url}/api/customers/#{public_id}")

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
