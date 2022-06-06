FROM ubuntu:18.04

ENV OFBIZ=18.12.05
ENV GRADLE_VERSION=6.5.1
ENV GRADLE_HOME=/opt/gradle/latest
ENV PATH=${GRADLE_HOME}/bin:${PATH}


# Install OpenJDK-8
RUN apt-get update && \
apt-get install -y openjdk-8-jdk unzip zip curl && \
apt-get install -y ant gradle && \
apt-get clean;

# ADD . apache-ofbiz-17.12.04 
ADD https://dlcdn.apache.org/ofbiz/apache-ofbiz-${OFBIZ}.zip apache-ofbiz-${OFBIZ}.zip
# ADD https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip gradle-${GRADLE_VERSION}-bin.zip

# RUN ls -a | grep ofbiz

# Fix certificate issues
RUN unzip apache-ofbiz-18.12.05.zip && cd apache-ofbiz-${OFBIZ} 
# && \
#     cd .. && unzip -d /opt/gradle gradle-${GRADLE_VERSION}-bin.zip && \
#     ln -s /opt/gradle/gradle-${GRADLE_VERSION} /opt/gradle/latest
RUN apt-get update && \
    apt-get install ca-certificates-java && \ 
    apt-get clean && \ 
    update-ca-certificates -f;
# Setup JAVA_HOME path 
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/ 
ENV JAVA_OPTS -Xmx3G 
# RUN export JAVA_HOME

#for passing in entity engine config VOLUME apache-ofbiz-17.12.04/framework/entity/config/
#for Derby Database VOLUME apache-ofbiz-17.12.04/runtime/data
#Expose port 
EXPOSE 8443
EXPOSE 8080

WORKDIR apache-ofbiz-${OFBIZ}

# Granting permission to gradlew 
# RUN chmod +x ./gradlew

RUN ./gradle/init-gradle-wrapper.sh || :
# RUN ./gradlew wrapper

RUN ./gradlew cleanAll loadAll
ENTRYPOINT  ./gradlew ofbiz