# build
docker build -t username/ona

# run
docker run -p 8001:80 -i -t -e MONGO_DB_HOST=172.17.42.1 -e PG_DB_HOST=172.17.42.1 username/ona

