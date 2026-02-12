FROM node:14
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# Run the test during the build process
RUN npm test
EXPOSE 3000
CMD ["npm", "start"]
