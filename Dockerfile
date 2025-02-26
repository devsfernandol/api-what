# Etapa 1: Construcción
FROM node:18-alpine AS build

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos de la aplicación
COPY package*.json ./

# Instala las dependencias de la aplicación
RUN npm install

# Copia el resto de la aplicación
COPY . .

# Construye la aplicación (si es aplicable)
# RUN npm run build

# Etapa 2: Ejecución
FROM node:18-alpine

# Instala las dependencias necesarias para Puppeteer
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont

# Establece variables de entorno para Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Crea un usuario para ejecutar la aplicación de manera segura
RUN addgroup -S pptruser && adduser -S pptruser -G pptruser

# Establece el directorio de trabajo
WORKDIR /app

# Copia las dependencias instaladas desde la etapa de construcción
COPY --from=build /app/node_modules ./node_modules

# Copia el resto de la aplicación
COPY --from=build /app .

# Cambia la propiedad de los archivos al usuario creado
RUN chown -R pptruser:pptruser /app

# Cambia al usuario no privilegiado
USER pptruser

# Expone el puerto en el que la aplicación se ejecutará
EXPOSE 3000

# Comando por defecto para ejecutar la aplicación
CMD ["node", "index.js"]
