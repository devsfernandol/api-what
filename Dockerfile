# Base Ubuntu 22.04
FROM ubuntu:22.04

# Evitamos preguntas interactivas en apt
ENV DEBIAN_FRONTEND=noninteractive

# 1) Instala Node.js 18
#    - Primero instalamos algunas utilidades como curl
RUN apt-get update && apt-get install -y curl \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 2) Instala librerías necesarias para Chrome/Puppeteer
RUN apt-get update && apt-get install -y \
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

# (Opcional) Si usas TypeScript, compila a dist/
RUN npm run build

# 7) Instala Chrome que Puppeteer requiere
RUN npx puppeteer browsers install chrome

# 8) Exponer el puerto (asumiendo tu app escucha en 3001)
EXPOSE 3001

# 9) Arranca tu aplicación compilada (ajusta si no se llama dist/app.js)
CMD ["node", "dist/app.js"]
