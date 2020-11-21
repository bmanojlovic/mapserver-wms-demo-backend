all:
	tar --owner=0 --group=0 -cvf entrypoint.tar.gz etc/apache2/conf.d srv/www entrypoint/entrypoint.sh 
