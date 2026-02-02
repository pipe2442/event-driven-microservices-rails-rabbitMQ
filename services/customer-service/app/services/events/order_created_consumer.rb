require "bunny"
require "json"

module Events
  class OrderCreatedConsumer
    QUEUE_NAME = "customer.orders_count"
    EXCHANGE_NAME = "orders.events"
    ROUTING_KEY = "order.created"

    DLX_NAME = "orders.dlx"
    DLQ_NAME = "customer.orders_count.dlq"
    DLQ_ROUTING_KEY = "order.created.dlq"

    RETRY_EXCHANGE = "orders.retry"
    RETRY_QUEUE = "customer.orders_count.retry"
    RETRY_ROUTING_KEY = "order.created.retry"
    RETRY_TTL_MS = (ENV.fetch("RABBITMQ_RETRY_TTL_MS", "10000").to_i)

    def initialize(url: ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@localhost:5672"), customer_repo: Customer)
      @url = url
      @customer_repo = customer_repo
    end

    def start
      conn = connect
      ch = conn.create_channel
      ch.prefetch(10)

      exchange = ch.topic(EXCHANGE_NAME, durable: true)

      dlx = ch.topic(DLX_NAME, durable: true)
      dlq = ch.queue(DLQ_NAME, durable: true)
      dlq.bind(dlx, routing_key: DLQ_ROUTING_KEY)

      retry_exchange = ch.topic(RETRY_EXCHANGE, durable: true)
      retry_queue = ch.queue(
        RETRY_QUEUE,
        durable: true,
        arguments: {
          "x-message-ttl" => RETRY_TTL_MS,
          "x-dead-letter-exchange" => EXCHANGE_NAME,
          "x-dead-letter-routing-key" => ROUTING_KEY
        }
      )
      retry_queue.bind(retry_exchange, routing_key: RETRY_ROUTING_KEY)

      queue = ch.queue(
        QUEUE_NAME,
        durable: true,
        arguments: {
          "x-dead-letter-exchange" => DLX_NAME,
          "x-dead-letter-routing-key" => DLQ_ROUTING_KEY
        }
      )
      queue.bind(exchange, routing_key: ROUTING_KEY)

      puts "[consumer] Listening on #{QUEUE_NAME} (#{ROUTING_KEY})..."

      queue.subscribe(manual_ack: true, block: true) do |delivery_info, props, body|
        handle_message(body)
        ch.ack(delivery_info.delivery_tag)
      rescue => e
        puts "[consumer] Error: #{e.message}"
        retries = retry_count(props)
        max_retries = ENV.fetch("RABBITMQ_MAX_RETRIES", "3").to_i

        if retries >= max_retries
          ch.nack(delivery_info.delivery_tag, false, false)
        else
          retry_exchange.publish(
            body,
            routing_key: RETRY_ROUTING_KEY,
            persistent: true,
            content_type: props.content_type,
            message_id: props.message_id,
            headers: props.headers
          )
          ch.ack(delivery_info.delivery_tag)
        end
      end
    end

    private

    def retry_count(props)
      deaths = Array(props.headers && props.headers["x-death"])
      entry = deaths.find { |d| d["queue"] == QUEUE_NAME }
      (entry && entry["count"] || 0).to_i
    end

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

          sleep_time = [ retries, 5 ].min
          puts "[consumer] RabbitMQ not ready, retrying in #{sleep_time}s..."
          sleep sleep_time
        end
      end
    end

    def handle_message(body)
      msg = JSON.parse(body)
      event_id = msg["event_id"]
      event_name = msg["event"]
      customer_public_id = msg.dig("data", "customer_public_id")
      return if event_id.nil? || customer_public_id.nil?

      customer = @customer_repo.find_by(public_id: customer_public_id)
      return if customer.nil?

      ApplicationRecord.transaction do
        ProcessedEvent.create!(
          event_id: event_id,
          event_name: event_name,
          occurred_at: msg["occurred_at"]
        )
        customer.increment!(:orders_count)
      end
    rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      # Idempotent - event already processed
    end
  end
end
