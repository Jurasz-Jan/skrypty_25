@echo off
SET /P keyword=Enter search keyword: 
docker-compose run --rm crawler -k "%keyword%"
pause
