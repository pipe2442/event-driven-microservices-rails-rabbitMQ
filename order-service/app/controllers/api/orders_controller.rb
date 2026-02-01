class Api::OrdersController < ApplicationController
    def index
      orders = Order.all
      render json: orders.as_json(only: [ :customer_public_id, :product_name, :quantity, :price, :created_at ], methods: [ :public_id ]), status: :ok
    end
  def create
    order_params = params.require(:order).permit(:customer_public_id, :product_name, :quantity, :price)

    order = Order.new(order_params)
    if order.save
      render json: { id: order.public_id }, status: :created
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
    params.require(:order).permit(:customer_public_id, :product_name, :quantity, :price)
  end
end
