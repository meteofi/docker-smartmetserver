FROM centos
MAINTAINER mikko@meteo.fi

ENV SMARTMET_DEVEL 0
ENV SMARTMET_LIBRARIES newbase macgyver gis spine locus tron imagine
ENV SMARTMET_ENGINES sputnik querydata geonames observation gis contour
ENV SMARTMET_PLUGINS timeseries download admin backend meta wfs frontend
ENV MAKEFLAGS -j2

RUN mkdir -p /usr/local/src/smartmet /smartmet/data /etc/smartmet/plugins /etc/smartmet/engines /var/log/smartmet /usr/share/smartmet/timezones /var/smartmet/timeseriescache

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    rpm -ivh https://download.postgresql.org/pub/repos/yum/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-3.noarch.rpm && \
    yum -y update && yum -y install \
    	   	   bzip2-devel \
		   cairo-devel cairo-gobject-devel \
     	   	   elfutils-devel \
		   file \
    	   	   gcc gcc-c++ \
    	   	   gdal-devel \
    	   	   geos-devel \
		   gdk-pixbuf2-devel \
    	   	   git \
		   grib_api grib_api-devel \
		   gobject-introspection-devel \ 
   	   	   jemalloc-devel \
    	   	   jsoncpp-devel \
		   libaio-devel \
		   libcroco-devel \
    	   	   libtool \
    	   	   libatomic \
    	   	   libconfig-devel \
    	   	   libicu-devel \
		   libjpeg-devel \
		   libpqxx-devel \
		   libspatialite-devel \
    	   	   make cmake imake \
    	   	   mariadb-devel \
		   mysql++-devel \
    	   	   netcdf-devel netcdf-cxx-devel \
    	   	   openssl-devel \
		   pango-devel \
    	   	   protobuf-devel protobuf-compiler \
    	   	   postgresql93-devel \
    	   	   python-devel\
    	   	   scons \
		   soci-devel soci-sqlite3-devel \
		   sqlite-devel \
    	   	   unzip \
    	   	   wget \
		   xqilla-devel \
		   xerces-c-devel \
    	   	   zlib-devel && \
    rpm -ivh http://www.nic.funet.fi/pub/mirrors/fedora.redhat.com/pub/epel/7/x86_64/c/cppformat-devel-2.0.0-1.el7.x86_64.rpm \
             http://www.nic.funet.fi/pub/mirrors/fedora.redhat.com/pub/epel/7/x86_64/c/cppformat-2.0.0-1.el7.x86_64.rpm \
	     https://meteo.fi/docker/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm \
	     https://meteo.fi/docker/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm

# ctpp2
RUN cd /usr/local/src/smartmet && \
    wget http://ctpp.havoc.ru/download/ctpp2-2.8.3.tar.gz && \
    tar zxvf ctpp2-2.8.3.tar.gz && \
    cd ctpp2-2.8.3 && \
    cmake . && \
    sed -i '/#include <stdlib.h>/a #include <unistd.h>' src/CTPP2FileSourceLoader.cpp && \
    make && \
    make install && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/ctpp2-2.8.3; fi && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/ctpp2-2.8.3.tar.gz; fi && \
# boost
    cd /usr/local/src/smartmet && \
    wget http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz && \
    tar zxf boost_1_55_0.tar.gz && \
    cd boost_1_55_0 && \
    ./bootstrap.sh --without-libraries=mpi,graph_parallel && \
    ./b2 $MAKEFLAGS && \
    ./b2 install && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/boost_1_55_0; fi && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/boost_1_55_0.tar.gz; fi && \
# librsvg
    cd /usr/local/src/smartmet && \
    wget http://ftp.gnome.org/pub/gnome/sources/librsvg/2.40/librsvg-2.40.6.tar.xz && \
    tar xvf librsvg-2.40.6.tar.xz && \
    cd librsvg-2.40.6 && \
    export CPPFLAGS="-I/usr/include/glib-2.0/" && \
    ./configure --disable-static --disable-gtk-doc --disable-gtk-theme --enable-introspection && \
    make  && make install && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/librsvg-2.40.6; fi && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/librsvg-2.40.6.tar.xz; fi && \
# json_spirit
    cd /usr/local/src/smartmet && \
    wget http://il.ma/json_spirit_v4.08.zip && \
    unzip json_spirit_v4.08.zip && \
    cd json_spirit_v4.08 && \
    mkdir build && cd build && \
    echo 'set (CMAKE_CXX_FLAGS "-fPIC -DJSON_UTF8")' >> ../json_spirit/CMakeLists.txt && \
    sed -e '/BOOST_SPIRIT_THREADSAFE/ s/^#//' -i ../json_spirit/json_spirit_reader_template.h && \
    cmake .. && \
    make  && make install && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/json_spirit_v4.08; fi && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/json_spirit_v4.08.zip; fi && \
# sparsehash
    cd /usr/local/src/smartmet && \
    git clone https://github.com/sparsehash/sparsehash.git && \
    cd sparsehash && \
    ./configure && \
    make && make install && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/sparsehash; fi && \
# prettyprint
    wget -O /usr/include/prettyprint.hpp https://raw.github.com/louisdx/cxx-prettyprint/master/prettyprint.hpp && \
# atomic_shared_ptr
    mkdir -p /usr/local/include/jssatomic && wget -O /usr/local/include/jssatomic/atomic_shared_ptr.hpp https://bitbucket.org/anthonyw/atomic_shared_ptr/raw/7bdef03f6536f4b9118d267b68da211297cc0143/atomic_shared_ptr && \
# ldconfig
echo "/usr/local/lib/" > /etc/ld.so.conf.d/local.conf && ldconfig -v && \
#
# SmartMet Libraries
#
   for LIBRARY in ${SMARTMET_LIBRARIES}; \
      do \
      	 cd /usr/local/src/smartmet && \
    	 git clone https://github.com/fmidev/smartmet-library-${LIBRARY}.git && \
    	 cd smartmet-library-${LIBRARY} && \
    	 make  && make install && \
	 strip /usr/lib64/libsmartmet-${LIBRARY}.so && \
    	 if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/smartmet-library-${LIBRARY}; fi \
      done && \
#
# SmartMet server
#
    cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-server.git && \
    cd smartmet-server && \
    make  && make install && \
    strip /usr/sbin/smartmetd && \
    if [ $SMARTMET_DEVEL -ne 1 ]; then rm -rf /usr/local/src/smartmet/smartmet-server; fi && \
#
# SmartMet Server Engines
#
    for ENGINE in ${SMARTMET_ENGINES}; \
      do \
	 cd /usr/local/src/smartmet && \    
         git clone https://github.com/fmidev/smartmet-engine-${ENGINE}.git && \
	 cd smartmet-engine-${ENGINE} && \
	 make  && make install  && \
	 if [ $SMARTMET_DEVEL -ne 1 ]; then strip /usr/share/smartmet/engines/${ENGINE}.so; rm -rf /usr/local/src/smartmet/smartmet-engine-${ENGINE}; fi \
      done && \
#
# SmartMet Server Plugins
#
      for PLUGIN in ${SMARTMET_PLUGINS}; \
      do \
      	 cd /usr/local/src/smartmet && \
    	 git clone https://github.com/fmidev/smartmet-plugin-${PLUGIN}.git && \
    	 cd smartmet-plugin-${PLUGIN} && \
	 if [ -f smartmet-plugin-frontend.spec ]; then sed -e 's/json_spirit\/json_spirit.h/json_spirit.h/g' -i source/Plugin.cpp; fi && \
    	 make  && make install && \
    	 if [ $SMARTMET_DEVEL -ne 1 ]; then strip /usr/share/smartmet/plugins/${PLUGIN}.so; rm -rf /usr/local/src/smartmet/smartmet-plugin-${PLUGIN}; fi \
      done && \
#
# Cleanup
#
      yum -y erase '*-devel' && \
      yum clean all && \
      rm -rf /usr/include/smartmet/ 
      
RUN wget -P /usr/share/smartmet/timezones https://raw.githubusercontent.com/boost-vault/date_time/master/date_time_zonespec.csv

COPY smartmetconf /etc/smartmet
COPY timezones /usr/share/smartmet/timezones

# Expose GeoServer's default port
EXPOSE 8080

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["smartmetd"]
