# Event-Driven Microservices (Rails + RabbitMQ)

## Requisitos del sistema

- Docker (>= 20)
- Docker Compose v2

> No necesitas instalar Ruby, PostgreSQL ni RabbitMQ localmente.

---

## Levantar el proyecto con Docker

Desde la raíz del repositorio:

```bash
docker compose up -d --build
```

Si quieres reconstruir desde cero:

```bash
docker compose down -v
docker compose build --no-cache
docker compose up -d
```

---

## Servicios incluidos

- **order-service** (Producer)
- **customer-service** (API)
- **customer-consumer** (Worker)
- **postgres-order** y **postgres-customer**
- **rabbitmq**

---

## Arquitectura (event-driven)

- **order-service** publica eventos en RabbitMQ cuando se crea una orden.
- **customer-service** consume esos eventos para actualizar datos (ej: `orders_count`).
- RabbitMQ usa un **exchange topic** (`orders.events`) con la routing key `order.created`.

**Flujo:**

1. `order-service` crea una orden.
2. Publica `order.created` con `event_id`.
3. `customer-consumer` escucha el evento.
4. Registra el `event_id` y actualiza el cliente.
5. Si llega un duplicado, se ignora (idempotencia).

---

## Acceder a RabbitMQ

- Management UI: http://localhost:15672  
- Usuario: `guest` / Password: `guest`

---

## Comandos útiles

Consola Rails dentro de contenedor:

```bash
docker compose exec order-service bin/rails c
```

o

```bash
docker compose exec customer-service bin/rails c
```

Migraciones:

```bash
docker compose exec customer-service bin/rails db:migrate
```

---

## Puertos

- order-service: `http://localhost:3000`
- customer-service: `http://localhost:3001`
- RabbitMQ UI: `http://localhost:15672`