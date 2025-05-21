#!/bin/bash

postgres -D /var/lib/postgresql/data &
PID=$!

until pg_isready; do
	  sleep 1
done

psql -U postgres -c "CREATE USER $REPLUSER REPLICATION LOGIN ENCRYPTED PASSWORD '$REPLPASSWORD';"

kill $PID
wait $PID

exec postgres -D /var/lib/postgresql/data
