#!/bin/bash

# Import IMDB datasets
datasets=(
    "name.basics"
    "title.akas"
    "title.basics"
    "title.crew"
    "title.episode"
    "title.principals"
    "title.ratings"
)

# sed 's/\\\\/\\\\\\\\/g': This command replaces each backslash (\) with two backslashes (\\). This is necessary because backslashes have special meaning in PostgreSQL's COPY command, and we need to escape them properly.
# sed 's/\\"/\\\\"/g': This command replaces each escaped double quote (\") with a double-escaped double quote (\\"). Again, this is to ensure that quotes within the data are properly escaped for PostgreSQL's COPY command.
for dataset in "${datasets[@]}"; do
    echo "Importing $dataset..."
    gunzip -c /imdb_data/$dataset.tsv.gz | sed 's/\\\\/\\\\\\\\/g' | sed 's/\\"/\\\\"/g' | psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\copy ${dataset//./_} FROM STDIN WITH (FORMAT csv, DELIMITER E'\t', QUOTE E'\b', HEADER true, NULL '\N', ENCODING 'UTF8');"
done

echo "All datasets imported successfully!"