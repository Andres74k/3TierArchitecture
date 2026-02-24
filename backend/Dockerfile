FROM node:18-alpine
WORKDIR /app

COPY package*.json ./
RUN npm install
RUN npm install pg @types/pg

COPY . .

RUN npm run build

COPY start.sh .

CMD ["sh", "start.sh"]
