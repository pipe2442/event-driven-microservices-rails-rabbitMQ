require "rails_helper"

RSpec.describe "Api::Customers", type: :request do
  describe "GET /api/customers" do
    it "returns a list of customers" do
      customer = create(:customer, name: "Ana", address: "Calle 1", orders_count: 2)

      get "/api/customers", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include(
        "id" => customer.public_id,
        "name" => "Ana",
        "address" => "Calle 1",
        "orders_count" => 2
      )
    end
  end

  describe "GET /api/customers/:id" do
    it "returns a customer by public_id" do
      customer = create(:customer)

      get "/api/customers/#{customer.public_id}", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include(
        "id" => customer.public_id,
        "name" => customer.name,
        "address" => customer.address,
        "orders_count" => customer.orders_count
      )
    end

    it "returns 404 when customer does not exist" do
      get "/api/customers/missing", headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/customers" do
    it "creates a customer" do
      payload = { customer: { name: "Maria", address: "Calle 9" } }

      post "/api/customers",
           params: payload.to_json,
           headers: { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["id"]).to be_present
      expect(body["name"]).to eq("Maria")
      expect(body["address"]).to eq("Calle 9")
      expect(body["orders_count"]).to eq(0)
    end

    it "returns 422 with validation errors" do
      payload = { customer: { name: "", address: "" } }

      post "/api/customers",
           params: payload.to_json,
           headers: { "ACCEPT" => "application/json", "CONTENT_TYPE" => "application/json" }

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["errors"]).to be_present
    end
  end
end
