# -----------------------------------
# Etapa 1: Construcción (Build)
# -----------------------------------
    FROM node:18-alpine AS build

    # Directorio de trabajo
    WORKDIR /app
    
    # Copia los archivos de dependencias
    COPY package*.json ./
    
    # Instala dependencias (producción y dev) para compilar TypeScript
    RUN npm install
    
    # Copia el resto del código
    COPY . .
    
    # Compila TypeScript -> dist/
    RUN npm run build
    
    
    # -----------------------------------
    # Etapa 2: Ejecución (Runtime)
    # -----------------------------------
    FROM node:18-alpine
    
    WORKDIR /app
    
    # Copiamos la carpeta dist (código compilado) y node_modules con dependencias instaladas
    COPY --from=build /app/dist ./dist
    COPY --from=build /app/node_modules ./node_modules
    COPY --from=build /app/package*.json ./
    
    # Exponer el puerto en el que escucha tu app (3001, ajusta si usas otro)
    EXPOSE 3001
    
    # Comando de arranque (usa el script "start" de tu package.json, que corre "node dist/app.js")
    CMD ["npm", "start"]
    