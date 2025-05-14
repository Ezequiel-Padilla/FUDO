# Rack API

## Requisitos

- Docker (opcional)
- PostgreSQL (opcional)
- Postman (opcional)
- Ruby 3.1+ y Bundler

# Sin conexión a base de datos
## Levantar con Docker (es necesario ```sudo``` en caso de no tener permisos)

```bash
docker build -t rack-api-without-database-connection .
docker run -p 9292:9292 rack-api-without-database-connection
```

## Levantar localmente

```bash
bundle install
rackup -o 0.0.0.0 -p 9292
```

# Conexión a base de datos
## Levantar con Docker (es necesario ```sudo``` en caso de no tener permisos)

```bash
cd rack-api-with-database-connection
docker compose up --build
```

## Levantar localmente

Debemos ingresar a nuestro motor de base de datos y crear la base de datos ```rack_api```, luego debemos ejecutar los siguientes comandos:
```bash
# Ingresar a la consola de PostgreSQL
psql -U postgres
# Crear la base de datos
CREATE DATABASE IF NOT EXISTS rack_api;
# Salir de la consola
\q
```

```bash
bundle install
ruby db/migrate.rb
ruby db/seeds.rb
rackup -o 0.0.0.0 -p 9292
```

# Postman
https://drive.google.com/file/d/1vQMkgu7riRaru_HB4ypNXtqwbP2nOqXz/view?usp=sharing