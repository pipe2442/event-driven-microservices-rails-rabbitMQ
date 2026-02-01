require "rails_helper"

RSpec.describe "Orders API", type: :request do
  it "returns order with customer data" do
    order = create(:order)

    stub_request(:get, %r{/api/customers/})
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
    expect(json["customer"]["name"]).to eq("Juan")
  end
end
