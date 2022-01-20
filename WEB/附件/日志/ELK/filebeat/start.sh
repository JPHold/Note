docker build -t local.harbor.com/library/filebeat-custom:6.7.0 .

docker run -d --network host \
  --name filebeat-6.7.0 \
  --user root \
  -e -strict.perms=false \
  --volume="/home/kong-log:/usr/share/filebeat/file-log" \
  --volume="/home/software/elk/filbeat/data:/usr/share/filebeat/data" \
  local.harbor.com/library/filebeat-custom:6.7.0
