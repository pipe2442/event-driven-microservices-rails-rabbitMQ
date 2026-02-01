class Api::OrdersController < ApplicationController
  def index
    orders = Order.select(:public_id, :customer_public_id, :product_name, :quantity, :price, :delivery_address, :created_at, :updated_at)
    render json: orders.map { |o|
      {
        id: o.public_id,
        customer_public_id: o.customer_public_id,
        product_name: o.product_name,
        quantity: o.quantity,
        price: o.price,
        delivery_address: o.delivery_address,
        created_at: o.created_at,
        updated_at: o.updated_at
      }
    }
  end

def create
  customer = Customers::Client.fetch_customer(order_params[:customer_public_id])

  unless customer
    return render json: { error: "Customer not found" }, status: :unprocessable_entity
  end

  order = Order.new(order_params)

  if order.save
    render json: {
      id: order.public_id,
      status: order.status,
      product_name: order.product_name,
      quantity: order.quantity,
      price: order.price,
      delivery_address: order.delivery_address,
      customer: {
        id: order.customer_public_id,
        name: customer["customer_name"],
        address: customer["address"],
        orders_count: customer["orders_count"]
      }
    }, status: :created
  else
    render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
  end
end

  def show
    order = Order.find_by(public_id: params[:id])
    if order
      render json: order, status: :ok
    else
      render json: { error: "Order not found" }, status: :not_found
    end
  end

  private

  def order_params
    params.require(:order).permit(:customer_public_id, :product_name, :quantity, :price, :delivery_address)
  end
end
