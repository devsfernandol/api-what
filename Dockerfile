# -----------------------------------
# Etapa 1: Construcción (Build)
# -----------------------------------
    FROM node:18-alpine AS build

    WORKDIR /app
    
    # Copia los archivos de dependencias
    COPY package*.json ./
    
    # Instala dependencias (incluyendo devDependencies para compilar TS)
    RUN npm install
    
    # Copia el resto del código
    COPY . .
    
    # Compila TypeScript -> dist/
    RUN npm run build
    
    
    # -----------------------------------
    # Etapa 2: Ejecución (Runtime)
    # -----------------------------------
    FROM node:18-alpine
    
    # Instala librerías necesarias para que Chrome/Chromium funcione
    RUN apk add --no-cache \
        nss \
        freetype \
        harfbuzz \
        ca-certificates \
        ttf-freefont \
        libstdc++ \
        # Opcional, si lo piden: 
        # udev \
        # gtk+3.0 \ 
        # (etc. según necesidades de Chrome)
    
    WORKDIR /app
    
    # Copiamos el dist compilado, node_modules y package.json
    COPY --from=build /app/dist ./dist
    COPY --from=build /app/node_modules ./node_modules
    COPY --from=build /app/package*.json ./
    
    # (Paso CRÍTICO) Instala la versión de Chrome que Puppeteer pide
    RUN npx puppeteer browsers install chrome
    
    # Expón el puerto donde corre tu app
    EXPOSE 3001
    
    # Arranca con "npm start" => que debe llamar a "node dist/app.js"
    CMD ["npm", "start"]
    