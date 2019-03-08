defmodule HelloGenserverWeb.Router do
  use HelloGenserverWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HelloGenserverWeb do
    pipe_through :api
  end
end
