require "bunny"
require "json"
require "securerandom"

module Events
  class RabbitmqPublisher
    EXCHANGE_NAME = "orders.events"

    def initialize(url: ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@localhost:5672"))
      @url = url
    end

    def publish_order_created(order)
      payload = {
        event_id: SecureRandom.uuid,
        event: "order.created",
        occurred_at: Time.now.utc.iso8601,
        data: {
          order_public_id: order.public_id,
          customer_public_id: order.customer_public_id
        }
      }

      publish(routing_key: "order.created", payload: payload)
    end

    private

    def publish(routing_key:, payload:)
      conn = Bunny.new(@url)
      conn.start

      ch = conn.create_channel
      exchange = ch.topic(EXCHANGE_NAME, durable: true)

      exchange.publish(
        JSON.generate(payload),
        routing_key: routing_key,
        persistent: true,
        content_type: "application/json",
        message_id: payload[:event_id]
      )
    ensure
      conn&.close
    end
  end
end
