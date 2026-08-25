FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      zsh git curl ca-certificates python3 procps \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/zsh tester
USER tester
WORKDIR /home/tester
