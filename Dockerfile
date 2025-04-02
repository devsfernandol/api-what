# Base Ubuntu 22.04
FROM ubuntu:22.04

# Evitamos preguntas interactivas
ENV DEBIAN_FRONTEND=noninteractive

# 1) Instala Node.js 18 (vía NodeSource)
RUN apt-get update && apt-get install -y curl gnupg2 \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 2) Instala librerías necesarias para Chrome/Puppeteer
RUN apt-get update && apt-get install -y \
    ca-certificates \
    fonts-liberation \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcairo2 \
    libx11-xcb1 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    xdg-utils \
    libasound2 \
    libgtk-3-0 \
    libpango-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 3) Directorio de trabajo
WORKDIR /app

# 4) Copia archivos de dependencias (package.json, package-lock.json, etc.)
COPY package*.json ./

# 5) Instala dependencias de tu proyecto
RUN npm install

# 6) Copia el resto de tu proyecto (src/, tsconfig.json, etc.)
COPY . .

# 7) (Opcional) Compila a dist/ si usas TypeScript
RUN npm run build

# 8) Instala Chrome que Puppeteer requiere
RUN npx puppeteer browsers install chrome

# 9) Expón el puerto (asumiendo tu app escucha en 3001)
EXPOSE 3001

# 10) Arranca tu aplicación compilada
CMD ["node", "dist/app.js"]
