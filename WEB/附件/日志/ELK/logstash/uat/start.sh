docker build -t local.harbor.com/library/logstash-custom:6.7.0 .
docker push local.harbor.com/library/logstash-custom:6.7.0
docker run -d --restart always --network host --name logstash-6.7.0 local.harbor.com/library/logstash-custom:6.7.0

