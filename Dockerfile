# ./Dockerfile

# Extend from the official Elixir image
FROM elixir:latest

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install hex package manager
# By using --force, we don’t need to type “Y” to confirm the installation
RUN mix local.hex --force

# Install mix dependencies
RUN mix deps.get

# Compile the project
RUN mix do compile

# Run server
EXPOSE 4000
# ENTRYPOINT ["/bin/bash"]
CMD elixir --sname node@$HOSTNAME --cookie hellogenserver -S mix phx.server
