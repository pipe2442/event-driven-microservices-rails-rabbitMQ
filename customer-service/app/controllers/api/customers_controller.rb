class Api::CustomersController < ApplicationController
  def show
    customer = Customer.find_by!(public_id: params[:id])

    render json: {
      customer_name: customer.name,
      address: customer.address,
      orders_count: customer.orders_count
    }
  end

  def index
    customers = Customer.order(:id).select(:public_id, :name, :address, :orders_count)
    render json: customers.map { |c|
      {
        id: c.public_id,
        customer_name: c.name,
        address: c.address,
        orders_count: c.orders_count
      }
    }
  end
end
