class Api::OrdersController < ApplicationController
  before_action :set_order, only: :show
  before_action :load_customer, only: %i[show create]

  def index
    @orders = Order.select(:public_id, :customer_public_id, :product_name, :quantity, :price, :delivery_address, :created_at, :updated_at)
    render :index
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      Events::RabbitmqPublisher.new.publish_order_created(@order)
      render :show, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render :show
  end

  private

  def set_order
    @order = Order.find_by!(public_id: params[:id])
  end

  def load_customer
    public_id = (params[:order] && params[:order][:customer_public_id]) || @order&.customer_public_id
    @customer = Customers::Client.fetch_customer(public_id) if public_id.present?
  end

  def order_params
    params.require(:order)
          .permit(:customer_public_id, :product_name, :quantity, :price, :delivery_address)
  end
end
