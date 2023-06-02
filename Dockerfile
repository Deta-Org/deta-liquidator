FROM detaprotocol/node:10.16.3-alpine

RUN adduser -S deta
RUN mkdir -p /home/deta/app
RUN chown deta -R /home/deta/app
USER deta

WORKDIR /home/deta/app

COPY ./.env* ./
COPY ./package.json ./package-lock.json ./
RUN npm ci --loglevel warn

COPY ./src ./src
RUN npm run build

CMD ["npm", "start"]
