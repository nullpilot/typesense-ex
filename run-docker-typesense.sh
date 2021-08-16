export TYPESENSE_API_KEY=xyz

mkdir /tmp/typesense-data

docker run -p 8108:8108 -v/tmp/typesense-data:/data typesense/typesense:0.21.0 \
  --data-dir /data --api-key=$TYPESENSE_API_KEY --name typesense-tmp

