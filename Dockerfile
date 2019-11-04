ARG nodeVersion=12.13.0-alpine
ARG nginxVersion=1.17.5

### User App ###
FROM node:$nodeVersion as user-app
LABEL authors="Hans Solo"
WORKDIR /usr/src/app
COPY . .
RUN npm i -g @angular/cli && npm i
RUN npm run build


### Node Server ###
FROM node:$nodeVersion as node-server
ARG nginxVersion
WORKDIR /usr/src/app
COPY ["package.json", "package-lock.json", "./"] 
RUN npm install --production && mv node_modules ../


### Final Image ###
FROM nginx:$nginxVersion-alpine
ARG nginxVersion
COPY --from=node-server /usr/src /usr/src
COPY --from=user-app /usr/src/app/www /usr/src/app/www/
COPY nginx.conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]