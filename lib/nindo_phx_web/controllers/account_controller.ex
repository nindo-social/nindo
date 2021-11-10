defmodule NindoPhxWeb.AccountController do
  use NindoPhxWeb, :controller

  import NindoPhxWeb.{Router.Helpers, ViewHelpers}

  # Pages to display

  def sign_up(conn, _params) do
    render(conn, "sign_up.html")
  end
  def sign_in(conn, _params) do
    render(conn, "sign_in.html")
  end

  def index(conn, _params) do
    case logged_in?(conn) do
      true  -> render(conn, "index.html")
      _     -> redirect(conn, to: account_path(conn, :sign_in))
    end

  end

  # Manage accounts

  def create_account(conn, params) do
    username = params["create_account"]["username"]
    password = params["create_account"]["password"]
    email = params["create_account"]["email"]

    case Nindo.Accounts.new(username, password, email) do
      {:ok, _account}   ->    redirect(conn, to: account_path(conn, :sign_in))
      {:error, error}   ->    render(conn, "sign_up.html", error: format_error(error))
    end
  end

  def login(conn, params) do
    username = params["login"]["username"]
    password = params["login"]["password"]
    id       = Nindo.Accounts.get_by(:username, username).id

    case Nindo.Accounts.login(username, password) do
      :ok ->
        conn
        |> put_session(:logged_in, true)
        |> put_session(:user_id, id)
        |> redirect(to: account_path(conn, :index))

      :wrong_password   ->    render(conn, "sign_in.html", error: %{title: "password", message: "Doesn't match"})
      _                 ->    render(conn, "sign_in.html", error: %{title: "error", message: "Something went wrong"})
    end
  end

  def logout(conn, _params) do
    conn
    |> put_session(:logged_in, false)
    |> put_session(:user_id, nil)
    |> redirect(to: account_path(conn, :sign_in))
  end

  # Private methods

  defp format_error(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      %{title: "#{acc}#{k}", message: String.capitalize joined_errors}
    end)
  end
end
