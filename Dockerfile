FROM ruby:3.3

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libvips \
    pkg-config \
    nodejs \
    npm \
    sqlite3 \
    libsqlite3-dev

# Define a pasta de trabalho
WORKDIR /app

# Copia apenas os arquivos de bibliotecas primeiro
COPY Gemfile Gemfile.lock ./

# Instala as bibliotecas (Gems)
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]