FROM openjdk:8-jdk

ARG version=free-8.11.0
ARG dataFile=clav-2020-01-04-false.ttl

ENV GRAPHDB_PARENT_DIR=/opt/graphdb
ENV GRAPHDB_HOME=${GRAPHDB_PARENT_DIR}/home

ENV GRAPHDB_INSTALL_DIR=${GRAPHDB_PARENT_DIR}/dist

ENV CLAV=${GRAPHDB_HOME}/data/repositories/CLAV

ADD graphdb-${version}-dist.zip /tmp

RUN mkdir -p ${GRAPHDB_PARENT_DIR} && \
    cd ${GRAPHDB_PARENT_DIR} && \
    unzip /tmp/graphdb-${version}-dist.zip && \
    rm /tmp/graphdb-${version}-dist.zip && \
    mv graphdb-${version} dist && \
    mkdir -p ${GRAPHDB_HOME} && \
    mkdir -p ${CLAV}

COPY ./CLAV-config.ttl ${CLAV}/config.ttl
COPY ./${dataFile} /tmp

RUN sed -i 's|# graphdb.home.data =|graphdb.home.data = ../home/data|' ${GRAPHDB_INSTALL_DIR}/conf/graphdb.properties

RUN /opt/graphdb/dist/bin/loadrdf -f -c ${CLAV}/config.ttl -m parallel /tmp/${dataFile}

ENV PATH=${GRAPHDB_INSTALL_DIR}/bin:$PATH

CMD ["/opt/graphdb/dist/bin/graphdb", "-Dgraphdb.home=/opt/graphdb/home", "-s"]

EXPOSE 7200
