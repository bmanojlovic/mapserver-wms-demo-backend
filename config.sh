#!/bin/sh

#--------------------------------------
#test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

echo "####################################"
echo "########### IMPORTANT ##############"
echo "####################################"

echo "If you would like to re-download data set"
echo "wget http://thematicmapping.org/downloads/TM_WORLD_BORDERS-0.3.zip" 

echo "JS aplication source"
echo "wget https://github.com/bmanojlovic/mapserver-wms-demo/archive/0.0.1/mapserver-wms-demo-0.0.1.tar.gz"

echo "####################################"
echo "########### IMPORTANT ##############"
echo "####################################"


# Simplification nothing smart here...
mv ./etc/apache2/conf.d/mod_fcgid.conf{,.orig}
cat << EOF_CFG > ./etc/apache2/conf.d/mod_fcgid.conf
# Documentation
# https://httpd.apache.org/mod_fcgid/mod/mod_fcgid.html
#
<IfModule fcgid_module>
  FcgidIPCDir /var/lib/apache2/fcgid/
  FcgidProcessTableFile /var/lib/apache2/fcgid/shm
</IfModule>

EOF_CFG

ln -s /srv/www/maps/data/Readme.txt /root/DATA_ATTRIBUTION

# enable apache modules
for mod in headers fcgid modcache ; do 
	a2enmod $mod
done
find /srv

exit 0
