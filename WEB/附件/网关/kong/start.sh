#mkdir /home/kong-log

# 在创建的目录下，创建日志文件和授权
#```shell
#touch dataServer.access.log
#chmod 777 dataServer.access.log

#touch dataServer.body.log
#chmod 777 dataServer.body.log
#```

#kong
#diocker-start
docker run -d --name kong-test --restart=always  --link postgres:kong-database  -p 18000:8000 -p 8443:8443   -p 8001:8001  -p 8444:8444 --volume="/home/software/kong-pro/config/nginx_kong.lua:/usr/local/share/lua/5.1/kong/templates/nginx_kong.lua" --volume="/home/kong-log/:/home/kong-log/"  local.harbor.com/pro-library/kong-custom:2.0.4

