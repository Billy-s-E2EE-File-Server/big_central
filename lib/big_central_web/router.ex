defmodule BigCentralWeb.Router do
  use BigCentralWeb, :router

  import BigCentralWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BigCentralWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BigCentralWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", BigCentralWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:big_central, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BigCentralWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/api", BigCentralWeb do
    pipe_through :api

    get "/dl_token", ApiController, :show
  end

  ## Authentication routes

  scope "/", BigCentralWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      layout: {BigCentralWeb.UserLive.Layouts, :app},
      on_mount: [{BigCentralWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/signup", UserLive.Signup
      live "/login", UserLive.Login
      live "/tokens", UserLive.Tokens
      live "/auth_app_success", UserLive.AuthAppSuccess
      live "/files", FilesLive.Index
    end

    get "/users/logout", UserSessionController, :delete
    post "/users/signup", UserSessionController, :create
    post "/users/login", UserSessionController, :create
  end
end
