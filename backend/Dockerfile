# Use Node.js base image
FROM node:20

# Create app directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Build the NestJS app
RUN npm run build

# Expose NestJS port
EXPOSE 3000

# Run the app
CMD ["npm", "run", "start:prod"]