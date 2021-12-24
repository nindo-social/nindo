defmodule NindoPhxWeb.Live.Components.FeedCustomizer do
  @moduledoc """
  LiveView for (un)following external RSS sources.
  """
  use NindoPhxWeb, :live_component
  alias NindoPhxWeb.{Endpoint, Live}

  alias Nindo.{Accounts, Feeds, RSS, RSS.YouTube}

  import Routes

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full flex-grow-0 rounded-md">
        <div class="pt-4">
          <.form let={f} for={:source} class="w-full flex flex-row" phx-submit="add" phx-target={@myself}>
            <span class="input input-l input-static">https://</span>
            <%= text_input f, :feed, autofocus: "autofocus", placeholder: "Add RSS feed...", class: "input input-m flex-grow w-full" %>
            <%= select f, :type, ["Blogger": :blogger, "Wordpress": :wordpress, "YouTube": :youtube, "Atom": :atom, "Custom": :custom], class: "input input-r"  %>
          </.form>
        </div>

        <%= if @feeds != [] do %>
              <h3 class="heading pt-4">Sources</h3>
        <% end %>

        <ul>

          <%= for feed <- @feeds do %>

            <li class="p-2 py-3 flex flex-row flex-wrap center-items">
              <%= if feed["icon"] != nil do %>
                <img class="w-8 mr-3" src={feed["icon"]} onerror="this.src='/images/rss.png'">
              <% else %>
                <span class="w-8 mr-3"></span>
              <% end %>
              <span class="mt-1">
                <%= live_patch feed["title"],
                    to: live_path(Endpoint, Live.Source, get_source_data(feed)),
                    phx_hook: "ScrollToTop"
                %>
              </span>

              <a class="mb-3 no-underline ml-auto hover:bg-gray-200 hover:text-gray-900 cursor-pointer w-auto px-2 rounded-full" phx-click="remove" phx-value-feed={feed["feed"]} phx-value-icon={feed["icon"]} phx-value-title={feed["title"]} phx-value-type={feed["type"]} phx-target={@myself}>
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                </svg>
              </a>
            </li>

          <% end %>
        </ul>
    </div>
    """
  end

  @impl true
  def handle_event("remove", params, socket) do
    Feeds.remove(params, socket.assigns.user)
    feeds = Accounts.get(socket.assigns.user.id).feeds

    {:noreply, socket
    |> assign(:feeds, feeds)}
  end

  @impl true
  def handle_event("add", %{"source" => %{"feed" => source, "type" => type}}, socket) do
    url = convert_link(type, source)

    case RSS.parse_feed(url, type) do
      {:error, _} ->
        send(self(), :invalid_feed)
        {:noreply, socket}

      feed ->
        Feeds.add(RSS.generate_source(feed, type, url), socket.assigns.user)
        feeds = Accounts.get(socket.assigns.user.id).feeds

        {:noreply, socket
        |> assign(:feeds, feeds)}
    end
  end

  defp get_source_data(feed) do
    "#{URI.encode(feed["feed"], &(&1 != ?/ and &1 != ?: and &1 != ??))}:#{feed["type"]}"
  end

  # This method is used to convert the YouTube custom urls or legacy
  # username to the yt.com/channel/id format, which is needed for the
  # RSS feeds to work. Converting is a expensive task, which also uses quota
  # on my YT API key. That's why I only convert it when adding the feed
  # and not every time I need to access the feed.
  defp convert_link(type, feed) do
    case type do
      "youtube" -> YouTube.to_channel_link(feed)
      _         -> feed
    end
  end
end
