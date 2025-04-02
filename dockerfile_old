# -----------------------------------
# Etapa 1: Construcción (Build)
# -----------------------------------
    FROM node:18-alpine AS build

    # 1. Instala pnpm de forma global
    RUN npm install -g pnpm
    
    # 2. Crea un directorio de trabajo
    WORKDIR /app
    
    # 3. Copia tu package.json y pnpm-lock.yaml
    COPY package.json pnpm-lock.yaml ./
    
    # 4. Instala dependencias
    RUN pnpm install
    
    # 5. Copia el resto del proyecto (incluyendo tsconfig.json, src/, etc.)
    COPY . .
    
    # 6. Compila TypeScript -> dist/
    RUN pnpm run build
    
    
    # -----------------------------------
    # Etapa 2: Ejecución (Runtime)
    # -----------------------------------
    FROM node:18-alpine
    
    # Instala librerías necesarias para Chrome
    RUN apk add --no-cache \
        nss \
        freetype \
        harfbuzz \
        ca-certificates \
        ttf-freefont \
        libstdc++
    
    # Directorio de trabajo
    WORKDIR /app
    
    # Copia dist, node_modules y package.json desde la etapa de build
    COPY --from=build /app/dist ./dist
    COPY --from=build /app/node_modules ./node_modules
    COPY --from=build /app/package.json ./
    COPY --from=build /app/pnpm-lock.yaml ./
    
    # (Clave) Fuerza que Puppeteer instale la versión de Chrome que necesita
    RUN npx puppeteer browsers install chrome
    
    # (Opcional) Crea un usuario sin privilegios
    RUN addgroup -S pptruser && adduser -S pptruser -G pptruser
    RUN chown -R pptruser:pptruser /app
    USER pptruser
    
    # Expón el puerto 3001
    EXPOSE 3001
    
    # Finalmente, arrancamos tu app (que ya está compilada en dist/app.js)
    CMD ["node", "dist/app.js"]
    