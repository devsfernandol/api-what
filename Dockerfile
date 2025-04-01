# Etapa 1: Construcción
FROM node:18-alpine AS build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# RUN npm run build  # Solo si tuvieras un proceso de build adicional

# Etapa 2: Ejecución
FROM node:18-alpine

# Instala las dependencias necesarias para Puppeteer (si tu bot las usa)
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN addgroup -S pptruser && adduser -S pptruser -G pptruser

WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app .

RUN chown -R pptruser:pptruser /app
USER pptruser

# Asegúrate de que tu index.js inicie en el puerto 3001
EXPOSE 3001
CMD ["node", "index.js"]
