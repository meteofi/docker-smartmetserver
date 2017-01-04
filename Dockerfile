FROM centos
MAINTAINER mikko@meteo.fi

RUN mkdir -p /usr/local/src/smartmet /smartmet/data /etc/smartmet/plugins /etc/smartmet/engines /var/log/smartmet /usr/share/smartmet/timezones /var/smartmet/timeseriescache

RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -ivh https://download.postgresql.org/pub/repos/yum/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-3.noarch.rpm

RUN yum -y update && yum -y install \
    	   	   bzip2-devel \
		   cairo-devel cairo-gobject-devel \
     	   	   elfutils-devel \
    	   	   gcc gcc-c++ \
    	   	   gdal-devel \
    	   	   geos-devel \
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
    yum clean all

RUN rpm -ivh http://www.nic.funet.fi/pub/mirrors/fedora.redhat.com/pub/epel/7/x86_64/c/cppformat-devel-2.0.0-1.el7.x86_64.rpm http://www.nic.funet.fi/pub/mirrors/fedora.redhat.com/pub/epel/7/x86_64/c/cppformat-2.0.0-1.el7.x86_64.rpm

COPY oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm  /usr/local/src/smartmet/
RUN rpm -ivh /usr/local/src/smartmet/oracle*.rpm

RUN cd /usr/local/src/smartmet && \
    wget http://ctpp.havoc.ru/download/ctpp2-2.8.3.tar.gz && \
    tar zxvf ctpp2-2.8.3.tar.gz && \
    cd ctpp2-2.8.3 && \
    cmake . && \
    sed -i '/#include <stdlib.h>/a #include <unistd.h>' src/CTPP2FileSourceLoader.cpp && \
    make && \
    make install 

RUN cd /usr/local/src/smartmet && \
    wget http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.gz && \
    tar zxf boost_1_55_0.tar.gz && \
    cd boost_1_55_0 && \
    ./bootstrap.sh --without-libraries=mpi,graph_parallel && \
    ./b2 && \
    ./b2 install 

RUN yum -y install file gdk-pixbuf2-devel

RUN cd /usr/local/src/smartmet && \
    wget http://ftp.gnome.org/pub/gnome/sources/librsvg/2.40/librsvg-2.40.6.tar.xz && \
    tar xvf librsvg-2.40.6.tar.xz && \
    cd librsvg-2.40.6 && \
    export CPPFLAGS="-I/usr/include/glib-2.0/" && \
    ./configure --disable-static --disable-gtk-doc --disable-gtk-theme --enable-introspection && \
    make -j4 && make install 

RUN wget -O /usr/include/prettyprint.hpp https://raw.github.com/louisdx/cxx-prettyprint/master/prettyprint.hpp

RUN mkdir -p /usr/local/include/jssatomic && wget -O /usr/local/include/jssatomic/atomic_shared_ptr.hpp https://bitbucket.org/anthonyw/atomic_shared_ptr/raw/7bdef03f6536f4b9118d267b68da211297cc0143/atomic_shared_ptr

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-library-newbase.git && \
    cd smartmet-library-newbase && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-library-macgyver.git && \
    cd smartmet-library-macgyver && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-library-gis.git && \
    cd smartmet-library-gis && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-library-spine.git && \
    cd smartmet-library-spine && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-server.git && \
    cd smartmet-server && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-engine-sputnik.git && \
    cd smartmet-engine-sputnik && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-engine-querydata.git && \
    cd smartmet-engine-querydata && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-library-locus.git && \
    cd smartmet-library-locus && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-engine-geonames.git && \
    cd smartmet-engine-geonames && \
    sed -e '/cfgvalidate/ s/^#*/#/' -i Makefile && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-engine-observation.git && \
    cd smartmet-engine-observation && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-engine-gis.git && \
    cd smartmet-engine-gis && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-plugin-timeseries.git && \
    cd smartmet-plugin-timeseries && \
    make -j4 && make install

RUN mkdir -p /usr/share/smartmet/timezones && \
    cd /usr/share/smartmet/timezones && \
    wget https://raw.githubusercontent.com/boost-vault/date_time/master/date_time_zonespec.csv

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-plugin-download.git && \
    cd smartmet-plugin-download && \
    sed -e '/cfgvalidate/ s/^#*/#/' -i Makefile && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/sparsehash/sparsehash.git && \
    cd sparsehash && \
    ./configure && make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-library-tron.git && \
    cd smartmet-library-tron && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-engine-contour.git && \
    cd smartmet-engine-contour && \
    sed -e '/cfgvalidate/ s/^#*/#/' -i Makefile && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-plugin-admin.git && \
    cd smartmet-plugin-admin && \
    sed -e '/cfgvalidate/ s/^#*/#/' -i Makefile && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-plugin-backend.git && \
    cd smartmet-plugin-backend && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-plugin-meta.git && \
    cd smartmet-plugin-meta && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-plugin-wfs.git && \
    cd smartmet-plugin-wfs && \
    sed -e 's/cfgvalidate/echo/g' -i Makefile && \
    make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-library-imagine.git && \
    cd smartmet-library-imagine && \
    make -j4 && make install

#RUN cd /usr/local/src/smartmet && \
#    git clone https://github.com/fmidev/smartmet-library-giza.git && \
#    cd smartmet-library-giza && \
#    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig && make -j4 && make install

RUN cd /usr/local/src/smartmet && \
    wget http://il.ma/json_spirit_v4.08.zip && \
    unzip json_spirit_v4.08.zip && \
    cd json_spirit_v4.08 && \
    mkdir build && cd build && \
    echo 'set (CMAKE_CXX_FLAGS "-fPIC -DJSON_UTF8")' >> ../json_spirit/CMakeLists.txt && \
    sed -e '/BOOST_SPIRIT_THREADSAFE/ s/^#//' -i ../json_spirit/json_spirit_reader_template.h && \
    cmake .. && \
    make && \
    make install

RUN cd /usr/local/src/smartmet && \
    git clone https://github.com/fmidev/smartmet-plugin-frontend.git && \
    cd smartmet-plugin-frontend && \
    sed -e 's/json_spirit\/json_spirit.h/json_spirit.h/g' -i source/Plugin.cpp && \
    make -j4 && make install


RUN echo "/usr/local/lib/" > /etc/ld.so.conf.d/local.conf
RUN ldconfig -v

COPY smartmetconf /etc/smartmet
COPY timezones /usr/share/smartmet/timezones

#RUN yum -y erase '*-devel' 
#RUN yum clean all
#RUN rm -rf /usr/local/src/smartmet

# Expose GeoServer's default port
EXPOSE 8080

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["bash"]
CMD ["smartmetd"]
