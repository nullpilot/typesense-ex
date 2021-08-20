export TYPESENSE_API_KEY=xyz

docker run -p 8108:8108 --tmpfs /data typesense/typesense:0.21.0 \
  --data-dir /data --api-key=$TYPESENSE_API_KEY --name typesense-tmp

