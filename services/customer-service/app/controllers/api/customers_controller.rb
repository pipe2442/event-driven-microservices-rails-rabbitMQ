class Api::CustomersController < ApplicationController
  def show
    @customer = Customer.find_by!(public_id: params[:id])

    render :show
  end

  def index
    @customers = Customer.order(:id).select(:public_id, :name, :address, :orders_count)
    render :index
  end

  def create
    @customer = Customer.new(customer_params)

    if @customer.save
      render :show, status: :created
    else
      render json: { errors: @customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def customer_params
    params.require(:customer).permit(:name, :address)
  end
end
