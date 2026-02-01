require "bunny"
require "json"

module Events
  class OrderCreatedConsumer
    QUEUE_NAME = "customer.orders_count"
    EXCHANGE_NAME = "orders.events"
    ROUTING_KEY = "order.created"

    def initialize(url: ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@localhost:5672"), customer_repo: Customer)
      @url = url
      @customer_repo = customer_repo
    end

    def start
      conn = connect
      ch = conn.create_channel
      ch.prefetch(10)

      exchange = ch.topic(EXCHANGE_NAME, durable: true)
      queue = ch.queue(QUEUE_NAME, durable: true)
      queue.bind(exchange, routing_key: ROUTING_KEY)

      puts "[consumer] Listening on #{QUEUE_NAME} (#{ROUTING_KEY})..."

      queue.subscribe(manual_ack: true, block: true) do |delivery_info, _props, body|
        handle_message(body)
        ch.ack(delivery_info.delivery_tag)
      rescue => e
        puts "[consumer] Error: #{e.message}"
        ch.nack(delivery_info.delivery_tag, false, true)
      end
    end

    private

    def connect
      retries = 0
      max_retries = ENV.fetch("RABBITMQ_MAX_RETRIES", "20").to_i

      loop do
        begin
          conn = Bunny.new(@url)
          conn.start
          return conn
        rescue Bunny::TCPConnectionFailed, Bunny::HostListDepleted
          retries += 1
          raise "RabbitMQ unavailable after #{max_retries} retries" if retries >= max_retries

          sleep_time = [retries, 5].min
          puts "[consumer] RabbitMQ not ready, retrying in #{sleep_time}s..."
          sleep sleep_time
        end
      end
    end

    def handle_message(body)
      msg = JSON.parse(body)
      customer_public_id = msg.dig("data", "customer_public_id")
      return if customer_public_id.nil?

      customer = @customer_repo.find_by(public_id: customer_public_id)
      return if customer.nil?

      customer.increment!(:orders_count)
    end
  end
end
