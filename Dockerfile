FROM docker.artifactory.apps.ecicd.dso.ncps.us-cert.gov/amq7/amq-broker:7.7
RUN curl -k -ucloudbees:AP6odshz4U5o6aD4pViKq9vsvReUHVPDSuamfb -o /opt/amq/web/console.war 'https://artifactory.apps.ecicd.dso.ncps.us-cert.gov/artifactory/generic-local/console.war'
RUN chown jboss:root /opt/amq/web/console.war
RUN chmod 664 /opt/amq/web/console.war
ENV AMQ_CLUSTER_PASSWORD=
USER root
# apply security vulnerability patch to address CVE
RUN yum install -y --setopt=tsflags=nodocs \
    --disablerepo=* \      
    --enablerepo=rhel-server-rhscl-7-rpms \
    --enablerepo=rhel-7-server-extras-rpms \
    --enablerepo=rhel-7-server-optional-rpms \
    --enablerepo=rhel-7-server-rpms \
    dbus-1.10.24-15.el7 dbus-libs-1.10.24-15.el7 libX11
RUN  yum -y clean all && \
     rm -rf /var/cache/yum
USER jboss
# Overwrite config items to drop advisory messages from full queue to avoid out of disk memory 
# $AMQ_HOME/conf/ is copied to ${INSTANCE_DIR}/etc/ by $AMQ_HOME/bin/configure_s2i_files.sh 
# before starting the broker.
COPY etc/broker.xml /opt/amq/conf/. 
RUN echo "Starting activemq container"
