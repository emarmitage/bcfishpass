# A minimal db for development and testing

## Create database dump file

Bootstrap database `bcfishpass_test` with fwapg, the latest bcfishpass schema, load selected data:

    ./build_db.sh

## Run bcfishpass model

Run model:

    ./test.sh

## Validation

1. obviously, did all jobs complete?
2. is modelled habitat / barrier count / etc reasonably equivalent to previous output? (see bcfishpass.log_* tables and views)

## Error: bt column does not exist in wcrp_watersheds
Solution: Add the column after building the db.  

    docker compose exec db psql -U postgres -d bcfishpass_test
    ALTER TABLE bcfishpass.wcrp_watersheds
        ADD COLUMN bt boolean;

## Export db table details to .txt
Export summary table to temp text file within the docker container:  

    docker compose exec db psql -U postgres -d bcfishpass_test

    \o /tmp/table_counts.txt
    SELECT format(
        'SELECT %L AS table_name, COUNT(*) AS row_count FROM %I.%I;',
        t.table_schema || '.' || t.table_name, t.table_schema, t.table_name
    )
    FROM information_schema.tables t
    WHERE t.table_type = 'BASE TABLE'
        AND t.table_schema NOT IN ('pg_catalog','information_schema')
    ORDER BY t.table_schema, t.table_name
    \gexec
    \o

Exit the bcfishpass_test db:  

    \q

Find the docker container id:

    docker ps

Export the temp file to WSL directory:

    docker cop <container-id>:/tmp/table_counts.txt /mnt/c/Users/USERNAME/bcfishpass/table_counts.txt


    