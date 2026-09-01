# ============================================================
# Stage 1 — Build frontend (React + Vite + TypeScript)
# ============================================================
FROM node:22-alpine AS frontend-builder

WORKDIR /app/frontend

# Install dependencies first (cache layer)
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci --ignore-scripts

# Copy source and build
COPY frontend/ ./
RUN npm run build

# ============================================================
# Stage 2 — Build backend (Go)
# ============================================================
FROM golang:1.25-alpine AS backend-builder

RUN apk add --no-cache gcc musl-dev

WORKDIR /app

# Download dependencies first (cache layer)
COPY go.mod go.sum ./
RUN go mod download

# Copy backend source
COPY backend/ ./backend/

# Build static binary
RUN CGO_ENABLED=1 GOOS=linux go build -ldflags="-s -w" -o /app/chatloop ./backend

# ============================================================
# Stage 3 — Production runtime
# ============================================================
FROM alpine:3.21

RUN apk add --no-cache ca-certificates tzdata

# Create non-root user
RUN addgroup -S chatloop && adduser -S chatloop -G chatloop

WORKDIR /app

# Copy compiled Go binary
COPY --from=backend-builder /app/chatloop ./chatloop

# Copy frontend dist (served by Go via STATIC_DIR)
COPY --from=frontend-builder /app/frontend/dist ./frontend/dist

# Create directories for persistent data
RUN mkdir -p /app/data && chown -R chatloop:chatloop /app

# .env will be injected via docker-compose environment/env_file
# WhatsApp session DB is stored in /app/data for persistence

ENV GIN_MODE=release
ENV STATIC_DIR=frontend/dist
ENV DB_PATH=/app/data/wa-assistant.db
ENV PORT=3030

EXPOSE 3030

USER chatloop

ENTRYPOINT ["./chatloop"]
