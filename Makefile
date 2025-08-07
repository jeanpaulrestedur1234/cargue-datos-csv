# Variables
CONTAINER_NAME=pg_container
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=mydb
VOLUME_NAME=pg_data

# Puerto expuesto
PORT=5432

# Archivos
CSV_FILE=data.csv
INIT_SQL=init.sql
SOLUTION_SQL=solution.sql

.PHONY: run stop clean load query

# Inicia contenedor de PostgreSQL
run:
	docker volume create $(VOLUME_NAME)
	docker run --name $(CONTAINER_NAME) \
		-e POSTGRES_USER=$(POSTGRES_USER) \
		-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		-e POSTGRES_DB=$(POSTGRES_DB) \
		-v $(VOLUME_NAME):/var/lib/postgresql/data \
		-p $(PORT):5432 \
		-d postgres:15
	@echo "Esperando a que arranque PostgreSQL..."
	sleep 5

# Cargar SQL inicial y archivo CSV
load:
	docker cp $(INIT_SQL) $(CONTAINER_NAME):/init.sql
	docker exec -i $(CONTAINER_NAME) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /init.sql
	docker cp $(CSV_FILE) $(CONTAINER_NAME):/data.csv
	docker exec -i $(CONTAINER_NAME) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -c "\copy my_table FROM '/data.csv' WITH CSV HEADER"

# Ejecutar consulta SQL adicional
query:
	docker cp $(SOLUTION_SQL) $(CONTAINER_NAME):/solution.sql
	docker exec -i $(CONTAINER_NAME) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /solution.sql

# Detener y eliminar contenedor
stop:
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || true

# Limpieza total (contenedor + volumen)
clean: stop
	docker volume rm $(VOLUME_NAME) || true
