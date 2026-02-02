# Event-Driven Microservices (Rails + RabbitMQ)

<p align="center">
  <img width="22%" alt="download" src="https://github.com/user-attachments/assets/31135e2d-7edb-4f8e-88ad-c6d46e0d81a0" />
  <img width="22%" alt="download-2" src="https://github.com/user-attachments/assets/f4590e97-dd13-4872-8a1b-19998404621d" />
  <img width="22%" alt="download-3" src="https://github.com/user-attachments/assets/109e48b6-e29f-4a40-af60-67b417bfabf4" />
  <img width="22%" alt="download-4" src="https://github.com/user-attachments/assets/3b0b4f33-d7e3-4663-82e2-8248ef4a296d" />
</p>


## ¿De qué trata este proyecto?

Este proyecto es un ejercicio sencillo que demuestra cómo construir una pequeña arquitectura **event-driven** utilizando **microservicios desarrollados con Ruby on Rails** y manejo de eventos mediante **RabbitMQ**.

La solución se basa en dos microservicios principales: **Orders** y **Customers**.

Ambos servicios se comunican de forma síncrona mediante **peticiones HTTP**, utilizando **HTTParty**.  
Adicionalmente, al crear una nueva orden, el **Order Service** publica un evento en RabbitMQ, el cual es procesado por un **consumer** que escucha dicho evento y actualiza un campo específico (`orders_count`) en la base de datos del **Customer Service**.

Este enfoque permite separar responsabilidades y manejar actualizaciones de forma asíncrona, siguiendo principios de una arquitectura orientada a eventos.

---

## Requisitos del sistema

- Docker (>= 20)
- Docker Compose v2

No es necesario instalar Ruby, PostgreSQL ni RabbitMQ localmente.  
Por simplicidad, toda la aplicación se encuentra completamente dockerizada.

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
- **postgres-order**
- **postgres-customer**
- **rabbitmq**

---

## Arquitectura (event-driven)

<img width="1214" height="710" alt="Screenshot 2026-02-01 at 10 25 31 PM" src="https://github.com/user-attachments/assets/63d351c7-989a-4f02-bdf3-1fa03b022560" />

- **order-service** publica eventos en RabbitMQ cuando se crea una orden.
- **customer-consumer** consume esos eventos para actualizar datos (ej: `orders_count`).
- RabbitMQ usa un **exchange topic** (`orders.events`) con la routing key `order.created`.

**Flujo:**

1. `order-service` crea una orden.
2. Publica `order.created` con `event_id`.
3. `customer-consumer` escucha el evento.
4. Registra el `event_id` y actualiza el cliente.
5. Si llega un duplicado, se ignora (idempotencia).

---

## Decisiones de diseño

- El mismo código base del **Customer Service** se utiliza tanto para la API como para el worker, en contenedores separados con responsabilidades distintas.
- RabbitMQ entrega mensajes **at-least-once**, por lo que el consumer es **idempotente** (deduplicación por `event_id`).
- Los mensajes que fallan se reintentan con **TTL** y, al superar `RABBITMQ_MAX_RETRIES`, se envían a la **DLQ** (`customer.orders_count.dlq`).

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
```bash
docker compose exec order-service bin/rails db:migrate
```

---

## Puertos

- order-service: `http://localhost:3000`
- customer-service: `http://localhost:3001`
- RabbitMQ UI: `http://localhost:15672`
