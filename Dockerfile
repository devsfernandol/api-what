# ------------------------------------------------
# Etapa 1: Construcción (Build) - Compila TypeScript
# ------------------------------------------------
    FROM node:18-alpine AS build

    WORKDIR /app
    
    # Copia tu package.json y lock file si lo tienes (package-lock.json)
    COPY package*.json ./
    
    # Instala dependencias
    RUN npm install
    
    # Copia el resto de archivos (src, tsconfig.json, etc.)
    COPY . .
    
    # Compila TypeScript -> dist/
    RUN npm run build
    
    
    # ------------------------------------------------
    # Etapa 2: Ejecución (Runtime) - Arranca tu bot
    # ------------------------------------------------
    FROM node:18-alpine
    
    # 1) Instala librerías mínimas para que Chrome funcione
    RUN apk add --no-cache \
        nss \
        freetype \
        harfbuzz \
        ca-certificates \
        ttf-freefont \
        libstdc++
    
    # 2) Crea un usuario sin privilegios (pptruser)
    RUN addgroup -S pptruser && adduser -S pptruser -G pptruser
    
    # 3) Puppeteer usará esta carpeta para instalar y buscar Chrome
    ENV HOME=/home/pptruser
    ENV PUPPETEER_CACHE_DIR=/home/pptruser/.cache/puppeteer
    
    # Crea la carpeta de caché con permisos
    RUN mkdir -p /home/pptruser/.cache/puppeteer && chown -R pptruser:pptruser /home/pptruser
    
    # Define el directorio de trabajo
    WORKDIR /app
    
    # Copia la carpeta dist (compilada), node_modules, y package.json desde la etapa build
    COPY --from=build /app/dist ./dist
    COPY --from=build /app/node_modules ./node_modules
    COPY --from=build /app/package*.json ./
    
    # Ajusta permisos de /app
    RUN chown -R pptruser:pptruser /app
    
    # 4) Cambiamos al usuario pptruser
    USER pptruser
    
    # 5) Instala Chrome EXACTO que Puppeteer requiera (guardado en /home/pptruser/.cache)
    RUN npx puppeteer browsers install chrome
    
    # 6) Expón el puerto 3001
    EXPOSE 3001
    
    # 7) Lanza tu servidor: "node dist/app.js"
    CMD ["node", "dist/app.js"]
    