FROM registry.opensuse.org/opensuse/tumbleweed:latest as builder

RUN zypper in -y yarn npm-default make gcc-c++
RUN zypper in -y git
RUN cd / && git clone https://github.com/bmanojlovic/mapserver-wms-demo-frontend.git
WORKDIR /mapserver-wms-demo-frontend
RUN yarn global add @quasar/cli
RUN yarn
RUN quasar build


###################### Real image with just built bits
FROM registry.opensuse.org/opensuse/tumbleweed:latest
RUN zypper in -y curl && curl https://download.opensuse.org/repositories/Application:/Geo/openSUSE_Tumbleweed/repodata/repomd.xml.key > $$.key \
    && rpm --import $$.key \
    && zypper  ar --refresh https://download.opensuse.org/repositories/Application:/Geo/openSUSE_Tumbleweed/ App:Geo \
    && zypper in -y unzip mapserver mapcache apache2-mod_fcgid tar \
    && zypper clean -a
COPY --from=builder /mapserver-wms-demo-frontend/dist/spa/ /srv/www/htdocs/
COPY ./srv/www/maps /srv/www/maps
COPY ./etc/apache2/conf.d/ /etc/apache2/conf.d
COPY ./entrypoint /entrypoint

EXPOSE 80 443

ENTRYPOINT [ "/entrypoint/entrypoint.sh" ]
