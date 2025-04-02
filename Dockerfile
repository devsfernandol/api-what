FROM node:18-bullseye

# ----------------------------------------------------------------
# Solución para el error de "invalid signature":
#  - Primero hacemos apt-get update ignorando errores (|| true)
#  - Luego instalamos debian-archive-keyring, que actualiza llaves GPG
#  - Después de eso, apt-get update normal no falla
# ----------------------------------------------------------------
RUN apt-get update || true
RUN apt-get install -y debian-archive-keyring

# 1) Instala librerías necesarias para Chrome en Debian
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

# 2) Configura el directorio de trabajo
WORKDIR /app

# 3) Copia los archivos de dependencias (package.json, package-lock.json, etc.)
COPY package*.json ./

# 4) Instala dependencias
RUN npm install

# 5) Copia todo el código del proyecto (src/, tsconfig.json, etc.)
COPY . .

# 6) Compila TypeScript -> dist/ (ajusta si tu script se llama distinto)
RUN npm run build

# 7) Instala la versión de Chrome que Puppeteer necesita
RUN npx puppeteer browsers install chrome

# 8) Expón el puerto (ajusta si tu app usa otro)
EXPOSE 3001

# 9) Arranca la aplicación compilada
CMD ["node", "dist/app.js"]
