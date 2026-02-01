class Api::OrdersController < ApplicationController
  before_action :set_order, only: :show
  before_action :load_customer, only: %i[show create]

  def index
    @orders = Order.select(:public_id, :customer_public_id, :product_name, :quantity, :price, :delivery_address, :created_at, :updated_at)
    render :index
  end

  def create
    result = Orders::Create.new(order_params).call

    if result.order
      @order = result.order
      render :show, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
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
  public_id = action_name == "create" ? order_params[:customer_public_id] : @order&.customer_public_id
  @customer = Customers::Client.new.fetch_customer(public_id) if public_id.present?
end

  def order_params
    params.require(:order).permit(:customer_public_id, :product_name, :quantity, :price, :delivery_address)
  end
end
