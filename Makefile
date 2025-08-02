# Variables
CONTAINER_NAME=pg_container
POSTGRES_USER=user
POSTGRES_PASSWORD=password
POSTGRES_DB=mydb

# Puerto expuesto
PORT=5432

# Archivos
CSV_FILE=data.csv
INIT_SQL=init.sql
SOLUTION_SQL=solution.sql

.PHONY: run stop clean load query

# Inicia contenedor de PostgreSQL
run:
	docker run --name $(CONTAINER_NAME) -e POSTGRES_USER=$(POSTGRES_USER) -e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) -e POSTGRES_DB=$(POSTGRES_DB) -p $(PORT):5432 -d postgres:15
	@echo "Esperando a que arranque PostgreSQL..."
	sleep 5
	docker cp $(INIT_SQL) $(CONTAINER_NAME):/init.sql
	docker exec -i $(CONTAINER_NAME) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /init.sql

# Cargar CSV
load:
	docker cp $(CSV_FILE) $(CONTAINER_NAME):/data.csv
	docker exec -i $(CONTAINER_NAME) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -c "\copy my_table(name, age) FROM '/data.csv' WITH CSV HEADER"

# Ejecutar consulta SQL
query:
	docker cp $(SOLUTION_SQL) $(CONTAINER_NAME):/solution.sql
	docker exec -i $(CONTAINER_NAME) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -f /solution.sql

# Detener y eliminar contenedor
stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)

# Limpieza total
clean: stop
