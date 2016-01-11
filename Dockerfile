FROM logstash

MAINTAINER qy

#install python2.7
RUN apt-get update -y
RUN apt-get install -y python2.7
RUN ln -s /usr/bin/python2.7 /usr/bin/python

#install amazon AWS CLI
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
RUN unzip awscli-bundle.zip
RUN ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
RUN rm awscli-bundle.zip

#download geo data
RUN curl "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz" -o "GeoLiteCity.dat.gz"
RUN gzip -dv GeoLiteCity.dat.gz
RUN mkdir /opt/logstash/GeoData/
RUN mv GeoLiteCity.dat /opt/logstash/GeoData/GeoLiteCity.dat

#add aws elasticsearch service plugin 
RUN /opt/logstash/bin/plugin install logstash-output-amazon_es

#add startup scirpts
#using cmd to copy/update configuration files and keys from aws S3 
#and then start the service
ADD scripts/startup_scripts  /usr/local/bin/startup_scripts
RUN chmod +111 /usr/local/bin/startup_scripts

EXPOSE 5000

CMD ["/usr/local/bin/startup_scripts"]
