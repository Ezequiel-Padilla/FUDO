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

```bash
docker build -t rack-api-with-database-connection .
docker run -p 9292:9292 rack-api-with-database-connection
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

```bash
bundle install
ruby db/migrate.rb
ruby db/seeds.rb
rackup -o 0.0.0.0 -p 9292
```

# Postman
https://drive.google.com/file/d/1vQMkgu7riRaru_HB4ypNXtqwbP2nOqXz/view?usp=sharing