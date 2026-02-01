class Orders::Create
  Result = Struct.new(:order, :errors)

  def initialize(params, publisher: Events::RabbitmqPublisher.new)
    @params = params
    @publisher = publisher
  end

  def call
    order = Order.new(@params)

    if order.save
      @publisher.publish_order_created(order)
      Result.new(order, nil)
    else
      Result.new(nil, order.errors.full_messages)
    end
  end
end
