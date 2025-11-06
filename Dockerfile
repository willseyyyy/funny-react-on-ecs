# --- Build stage ---
FROM node:18-alpine AS builder
WORKDIR /app
COPY react-app/ ./

# install project deps and also ensure vite react plugin is present
RUN npm install --legacy-peer-deps
# some setups don't list @vitejs/plugin-react in package.json — install it explicitly
RUN npm install --save-dev @vitejs/plugin-react --legacy-peer-deps

# build the static site
RUN npm run build

# --- Serve stage ---
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
