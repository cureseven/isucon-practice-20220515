all: isuda isutar

deps:
	go get github.com/go-sql-driver/mysql
	go get github.com/gorilla/mux
	go get github.com/gorilla/sessions
	go get github.com/Songmu/strrand
	go get github.com/unrolled/render

isuda: deps
	go build -o isuda isuda.go type.go util.go

isutar: deps
	go build -o isutar isutar.go type.go util.go

.PHONY: *

gogo: stop-services build truncate-logs start-services bench

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isuda.go
	sudo systemctl stop isutar.go
	sudo systemctl stop mysql

build:
	GOPATH=~/webapp/go make isutar isuda

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log
	sudo truncate --size 0 /var/log/mysql/mysql-slow.log && sudo chmod 666 /var/log/mysql/mysql-slow.log
	sudo truncate --size 0 /var/log/mysql/error.log

start-services:
	sudo systemctl start mysql
	sudo systemctl start isutar.go
	sudo systemctl start isuda.go
	sudo systemctl start nginx

bench:
	cd ~/isucon6q && ./isucon6q-bench