# Event-Driven Microservices (Rails + RabbitMQ)

<p align="center">
  <img width="22%" alt="download" src="https://github.com/user-attachments/assets/31135e2d-7edb-4f8e-88ad-c6d46e0d81a0" />
  <img width="22%" alt="download-2" src="https://github.com/user-attachments/assets/f4590e97-dd13-4872-8a1b-19998404621d" />
  <img width="22%" alt="download-3" src="https://github.com/user-attachments/assets/109e48b6-e29f-4a40-af60-67b417bfabf4" />
  <img width="22%" alt="download-4" src="https://github.com/user-attachments/assets/3b0b4f33-d7e3-4663-82e2-8248ef4a296d" />
</p>

## What is this project about?

This project is a simple exercise that demonstrates how to build a small **event-driven architecture** using **microservices developed with Ruby on Rails** and event handling through **RabbitMQ**.

The solution is based on two main microservices: **Orders** and **Customers**.

Both services communicate synchronously via **HTTP requests**, using **HTTParty**.  
Additionally, when a new order is created, the **Order Service** publishes an event to RabbitMQ, which is processed by a **consumer** that listens to the event and updates a specific field (`orders_count`) in the **Customer Service** database.

This approach allows responsibilities to be separated and updates to be handled asynchronously, following event-driven architecture principles.

## System Requirements

- Docker (>= 20)
- Docker Compose v2

There is no need to install Ruby, PostgreSQL, or RabbitMQ locally.  
For simplicity, the entire application is fully dockerized.

## Running the project with Docker

From the root of the repository:


```
docker compose up -d --build
```

To rebuild everything from scratch:

```
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

---

How to test the application (end-to-end)

The application already includes test customers automatically loaded via seeds, so there is no need to create users manually.

### 1. Fetch an existing customer
```
GET http://localhost:3001/api/customers/11111111-1111-1111-1111-111111111111
```

Expected response:
```
{
  "id": "11111111-1111-1111-1111-111111111111",
  "name": "John Doe",
  "email": "john.doe@test.com",
  "orders_count": 0
}
```

This customer exists because the customer-service loads default data through seeds.

### 2. Create an order for that customer
```
POST http://localhost:3000/api/orders
```

Payload:
```
{
  "order": {
    "customer_public_id": "11111111-1111-1111-1111-111111111111",
    "product_name": "Laptop",
    "quantity": 1,
    "price": 1200.00,
    "delivery_address": "Calle 123 #45-67, Medellín"
  }
}
```

What happens internally:

- The order is created in the order-service
- The order.created event is published to RabbitMQ
- The customer-consumer processes the event
- The customer's orders_count is incremented

### 3. Verify the updated counter (event-driven)
```
GET http://localhost:3001/api/customers/11111111-1111-1111-1111-111111111111
```

Expected response:
```
{
  "id": "11111111-1111-1111-1111-111111111111",
  "name": "John Doe",
  "email": "john.doe@test.com",
  "orders_count": 1
}
```
---

## Included Services

- **order-service (Producer)
- **customer-service** (API)
- **customer-consumer** (Worker)
- **postgres-order**
- **postgres-customer**
- **rabbitmq**

---

## Architecture (event-driven)

<img width="1214" height="710" alt="Screenshot 2026-02-01 at 10 25 31 PM" src="https://github.com/user-attachments/assets/63d351c7-989a-4f02-bdf3-1fa03b022560" />

- order-service publishes events to RabbitMQ when an order is created.
- customer-consumer consumes those events to update data (e.g. orders_count).
- RabbitMQ uses a topic exchange (orders.events) with the routing key order.created.

**Flujo:**

1. order-service creates an order.
2. Publishes order.created with an event_id.
3. customer-consumer listens to the event.
4. Stores the event_id and updates the customer.
5. If a duplicate event arrives, it is ignored (idempotency).

---

## Design Decisions

- The same Customer Service codebase is used for both the API and the worker, running in separate containers with different responsibilities.
- RabbitMQ delivers messages at-least-once, so the consumer is idempotent (deduplication by event_id).
- Failed messages are retried using TTL and, after exceeding RABBITMQ_MAX_RETRIES, are sent to the DLQ (customer.orders_count.dlq).

---

## Access RabbitMQ

- Management UI: http://localhost:15672
- User: `guest` / Password: `guest`

---

## Useful Commands

Rails console inside a container:

```
docker compose exec order-service bin/rails c
```

or

```
docker compose exec customer-service bin/rails c
```

Run migrations:

```
docker compose exec customer-service bin/rails db:migrate
```
```
docker compose exec order-service bin/rails db:migrate
```

---

## Ports

- order-service: `http://localhost:3000`
- customer-service: `http://localhost:3001`
- RabbitMQ UI: `http://localhost:15672`
