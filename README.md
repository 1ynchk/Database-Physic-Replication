# Database-Physic-Replication

# Introduction

This project was made as a reminder how to set physical replication system.
 
Project contains basic settings for this purpose, not more. 

Approaches, which were viewed in the description section below, were applied in Docker containers.

# Description

In the project was set physical replication system. 

There are two instances of database: primary(master) and standby(slave).

P.S. 
We'll skip the process of installation a PostgreSQL instance to the server.
All the pathes match usuall pathes.

## Master instance

1) Previously, we should stop database cluster if it is running:
```
pg_ctl stop 

# or
# sudo systemctl stop postgresql
```

2) After, we need to renew our <i>postgresql.conf</i>, adding new params:
```
archive_mode=on
archive_command='cp %p /db/pg_data/%f'
max_wal_senders=2
wal_keep_size=50
wal_log_hints=on
wal_level=replica
listen_addresses='*'
```

Also, you can redefine existing params the way you want.

3) After this, <i>pg_hba.conf</i> should be rewritten. We add the following row to the config:
```
host replication <repluser> <current_host> scram-sha-256
```

5) Finally, we can start our server:
```
postgres -D /path/to/postgres/data

# or 
# pg_ctl start -U postgres -D /path/to/postgres/data
```

5) In the master cluster we should create a new replication user. 
It is being created with the following command in `psql` command-line tool:
```
CREATE USER <repluser> REPLICATION PASSWORD 'examplepassword';
```

## Slave instance

1) The first what we need is to stop our cluster;

2) The second is to change `listen_addresses` to 'localhost, <master_instance_host>':
```
listen_addresses='localhost, <master_instance_host>'
```

3) Also, it is necessary to delete all the insides of the data folder:
```
rm -rf /path/to/data/*
``` 

4) After this, we should make a backup:
```
pg_basebackup -R -h <master_instance_host> -w -D /path/to/data -U <repluser>
```

5) Start server.


# Getting started

```
git clone https://github.com/1ynchk/Database-Physic-Replication
cd Database-Physic-Replication
docker-compose up
```

If you have a desire you can change database user's name and password and replication user's name and password in two instances:
```
services:

  db_master:

    ...

    build:
      context: ./master
      dockerfile: dockerfile
      args:
        REPLUSER: repluser
        REPLPASSWORD: 123451098765qazwsx
        MASTERHOST: 192.168.0.3/24
    environment:
      POSTGRES_PASSWORD: postgrespassword
      POSTGRES_USER: postgres

  db_slave:

    ...

    build:
      context: ./slave
      dockerfile: dockerfile
      args:
        REPLUSER: repluser
        MASTERHOST: 192.168.0.2
        MASTERPORT: 5432
        REPLPASSWORD: repluserpassword
    environment:
      POSTGRES_PASSWORD: postgrespassword
      POSTGRES_USER: postgres
      POSTGRES_BD: starshop
```
