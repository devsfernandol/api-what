# Base Ubuntu 22.04
FROM ubuntu:22.04

# Evitamos preguntas interactivas en apt
ENV DEBIAN_FRONTEND=noninteractive

# Desactiva chequeos de firmas y fechas en apt (solo para este contenedor)
# Esto ignora la validez GPG y la fecha "caducada" de los repos.
# ADVERTENCIA: Inseguro en producción
RUN apt-get update -o Acquire::Check-Valid-Until=false \
                   -o Acquire::Check-Date=false \
                   -o Acquire::AllowInsecureRepositories=true \
                   -o Acquire::AllowDowngradeToInsecureRepositories=true \
    && apt-get install -y --allow-unauthenticated curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update -o Acquire::Check-Valid-Until=false \
                     -o Acquire::Check-Date=false \
                     -o Acquire::AllowInsecureRepositories=true \
                     -o Acquire::AllowDowngradeToInsecureRepositories=true \
    && apt-get install -y --allow-unauthenticated nodejs \
    && rm -rf /var/lib/apt/lists/*

# Instala librerías necesarias para Chrome/Puppeteer, también sin verificación
RUN apt-get update -o Acquire::Check-Valid-Until=false \
                   -o Acquire::Check-Date=false \
                   -o Acquire::AllowInsecureRepositories=true \
                   -o Acquire::AllowDowngradeToInsecureRepositories=true \
    && apt-get install -y --allow-unauthenticated \
       ca-certificates \
       fonts-liberation \
       libnss3 \
       libatk-bridge2.0-0 \
       libx11-xcb1 \
       libdrm2 \
       libxkbcommon0 \
       libxcomposite1 \
       libxdamage1 \
       libxfixes3 \
       libxrandr2 \
       libgbm1 \
       xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# 3) Directorio de trabajo
WORKDIR /app

# 4) Copia archivos de dependencias
COPY package*.json ./

# 5) Instala dependencias
RUN npm install

# 6) Copia el resto de tu proyecto (src/, tsconfig.json, etc.)
COPY . .

# 7) (Opcional) Compila a dist/ si usas TypeScript
RUN npm run build

# 8) Instala Chrome que Puppeteer requiere
RUN npx puppeteer browsers install chrome

# 9) Exponer el puerto (asumiendo tu app escucha en 3001)
EXPOSE 3001

# 10) Arranca tu aplicación compilada (ajusta si no se llama dist/app.js)
CMD ["node", "dist/app.js"]
