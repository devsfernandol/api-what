FROM node:18-bullseye

# 1) Instala librerías que Chrome necesita
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
    # Limpieza de apt para reducir espacio (opcional)
    && rm -rf /var/lib/apt/lists/*

# 2) Directorio de trabajo
WORKDIR /app

# 3) Copia tus package.json / lockfiles
COPY package*.json ./
# Si usas PNPM, copia pnpm-lock.yaml y primero instala pnpm:
# RUN npm install -g pnpm

# 4) Instala dependencias (con npm o pnpm)
RUN npm install

# 5) Copia todo tu código al contenedor (src/, tsconfig.json, etc.)
COPY . .

# 6) Compila TypeScript -> dist/
RUN npm run build

# 7) Instala la versión de Chrome que Puppeteer requiere
RUN npx puppeteer browsers install chrome

# 8) Expón el puerto en el que corre tu app
EXPOSE 3001

# 9) Arranca tu aplicación compilada
# Ajusta según tu proyecto: "node dist/app.js" o "npm start" si tu script "start" lo llama
CMD ["node", "dist/app.js"]
