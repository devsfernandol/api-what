# -----------------------------------
# Etapa 1: Construcción (Build)
# -----------------------------------
    FROM node:18-alpine AS build

    # Crea un directorio de trabajo
    WORKDIR /app
    
    # Copia el package.json y package-lock.json (si existe)
    COPY package*.json ./
    
    # Instala dependencias de producción y desarrollo
    # (usado para compilar TypeScript)
    RUN npm install
    
    # Copia todo el proyecto
    COPY . .
    
    # Compila TypeScript -> dist/
    RUN npm run build
    
    
    # -----------------------------------
    # Etapa 2: Ejecución (Runtime)
    # -----------------------------------
    FROM node:18-alpine
    
    WORKDIR /app
    
    # Copiamos la carpeta dist (resultado de la compilación)
    # y los node_modules con dependencias instaladas
    COPY --from=build /app/dist ./dist
    COPY --from=build /app/node_modules ./node_modules
    COPY --from=build /app/package*.json ./
    
    # Expón el puerto 3001 (o el que uses en tu app)
    EXPOSE 3001
    
    # Comando por defecto: "npm start" => ejecuta "node ./dist/app.js"
    CMD ["npm", "start"]
    