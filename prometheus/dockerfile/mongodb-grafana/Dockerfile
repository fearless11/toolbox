From node:14.8.0

ADD ./mongodb-grafana /usr/local/mongodb-grafana
WORKDIR /usr/local/mongodb-grafana
RUN npm config set registry http://mirrors.cloud.tencent.com/npm/
RUN npm install 
EXPOSE 3333
CMD ["npm","run","server"]
