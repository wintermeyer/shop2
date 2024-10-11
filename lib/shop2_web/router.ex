defmodule Shop2Web.Router do
  use Shop2Web, :router

  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {Shop2Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
  end

  scope "/", Shop2Web do
    ash_authentication_live_session :authenticated do
      # use `live_user_required` for routes that must have an authenticated user
      # live "/exmaple_one", ExampleLive, on_mount: {Shop2Web.LiveUserAuth, :live_user_required}

      # use `live_user_optional` for routes that may have an authenticated user
      # live "/example_two", Example2Live, on_mount: {Shop2Web.LiveUserAuth, :live_user_optional}

      # use `live_user_optional` for routes that must not have an authenticated user
      # live "/example_three", Example3Live, on_mount: {Shop2Web.LiveUserAuth, :live_no_user}
    end
  end

  scope "/", Shop2Web do
    pipe_through :browser

    get "/", PageController, :home
    auth_routes AuthController, Shop2.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{Shop2Web.LiveUserAuth, :live_no_user}],
                  overrides: [Shop2Web.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth"
  end

  # Other scopes may use custom stacks.
  # scope "/api", Shop2Web do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:shop2, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: Shop2Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
