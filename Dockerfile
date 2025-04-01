# -----------------------------------
# Etapa 1: Construcción (Build)
# -----------------------------------
    FROM node:18-alpine AS build

    WORKDIR /app
    
    # Copia los archivos de dependencias
    COPY package*.json ./
    
    # Instala dependencias
    RUN npm install
    
    # (PASO CLAVE) Instala la versión de Chrome necesaria
    RUN npx puppeteer browsers install chrome
    
    # Copia el resto del código
    COPY . .
    
    # Compila TypeScript -> dist/
    RUN npm run build
    
    
    # -----------------------------------
    # Etapa 2: Ejecución (Runtime)
    # -----------------------------------
    FROM node:18-alpine
    
    WORKDIR /app
    
    # Copiamos dist, node_modules y package*.json
    COPY --from=build /app/dist ./dist
    COPY --from=build /app/node_modules ./node_modules
    COPY --from=build /app/package*.json ./
    
    # Exponemos el puerto en el que escucha tu app
    EXPOSE 3001
    
    # Arranca con "npm start" => "node dist/app.js"
    CMD ["npm", "start"]
    