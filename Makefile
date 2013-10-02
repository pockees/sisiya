
all: compile

compile:
	cd src && ./bootstrap create && ./configure && make && cd ..
### for edbc
	cd edbc && make clean && make && cd ..
### for the server code
	cd sisiya_server/ && ./bootstrap create && ./configure && make clean && make && cd ..
install:
	#cd src/ && make "install_root=$(install_root)" install && cd ..
	#cd edbc && make "install_root=$(install_root)" install && cd ..
	#cd sisiya_server && make "install_root=$(install_root)" install && cd ..
	cd src/ && make "install_root=/home/emutlu/rpm/BUILD" install && cd ..
	cd edbc && make "install_root=/home/emutlu/rpm/BUILD" install && cd ..
	cd sisiya_server && make "install_root=/home/emutlu/rpm/BUILD" install && cd ..
