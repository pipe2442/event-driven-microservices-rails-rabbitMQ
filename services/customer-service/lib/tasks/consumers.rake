namespace :consumers do
  desc "Start RabbitMQ consumers"
  task orders_count: :environment do
    Events::OrderCreatedConsumer.new.start
  end
end
