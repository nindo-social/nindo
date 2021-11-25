defmodule NindoPhxWeb.UIComponent do
  @moduledoc false

  use Phoenix.Component
  use Phoenix.HTML

  alias Nindo.{Accounts, Format}
  import NindoPhxWeb.Router.Helpers

  import Nindo.Core

  def sidebar(assigns) do
    ~H"""
      <div class="sidebar">
        <ul class="flex items-center justify-center flex-wrap flex-row xl:flex-col xl:items-start xl:justify-start">
          <li class="header-item"><%= link safe("<i class='fas fa-home icon'></i> Home"), to: social_path(@conn, :index) %></li>
          <li class="header-item"><%= link safe("<i class='fas fa-compass icon'></i> Discover"), to: social_path(@conn, :discover) %></li>
          <li class="header-item"><%= link safe("<i class='fas fa-stream icon'></i> Sources"), to: social_path(@conn, :sources) %></li>
          <li class="header-item"><%= link safe("<i class='fas fa-user icon'></i> Settings"), to: account_path(@conn, :index) %></li>
        </ul>
      </div>
    """
  end

  def account_header(assigns) do
    account = Accounts.get(assigns.id)

    ~H"""
      <p class="header-item">
        <a href="/account"><i class="fas fa-user-circle mr-1"></i> <%=
          Format.display_name(account.username)
        %></a>
      </p>

      <%= link "Logout", to: account_path(@conn, :logout), class: "header-item header-button btn-secondary hidden lg:block" %>
    """
  end
end
