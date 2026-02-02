require "rails_helper"

RSpec.describe "Orders API", type: :request do
  let(:base_url) { ENV.fetch("CUSTOMER_SERVICE_URL", "http://localhost:3001") }

  it "returns order with customer data" do
    order = create(:order)

    stub_request(:get, "#{base_url}/api/customers/#{order.customer_public_id}")
      .to_return(
        status: 200,
        body: {
          id: order.customer_public_id,
          name: "Juan",
          address: "Calle 1",
          orders_count: 0
        }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    get "/api/orders/#{order.public_id}"

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json["id"]).to eq(order.public_id)
    expect(json["customer"]["name"]).to eq("Juan")
    expect(WebMock).to have_requested(:get, "#{base_url}/api/customers/#{order.customer_public_id}").once
  end

  it "returns order without customer data when customer is missing" do
    order = create(:order)

    stub_request(:get, "#{base_url}/api/customers/#{order.customer_public_id}")
      .to_return(status: 404, body: "", headers: { "Content-Type" => "application/json" })

    get "/api/orders/#{order.public_id}"

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json["id"]).to eq(order.public_id)
    expect(json).not_to have_key("customer")
  end
end
