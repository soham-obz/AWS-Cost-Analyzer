FROM python:3.13-alpine
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY pyproject.toml .
RUN uv sync
COPY my_mcp_server.py .

# Change ownership to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

ENV HOST=0.0.0.0
ENV PORT=8000

EXPOSE 8000 


HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1  http://127.0.0.1:8000/|| exit 1

CMD ["uv", "run", "my_mcp_server.py"]