defmodule NindoPhxWeb.PostComponent do
  @moduledoc """
  Component for displaying posts.
  """
  use Phoenix.Component
  use Phoenix.HTML

  alias Nindo.{Format, RSS.YouTube}
  alias NindoPhxWeb.{Endpoint, Live}
  import NindoPhxWeb.Router.Helpers

  import Nindo.Core

  @doc """
  The default post. Will be renderd in feeds for both users and external RSS posts.

  Only posts with more than 450 characters are counted as 'blogposts', everything else is a 'statusupdate'. Blogposts do have a title, statusupdates do not.
  """
  def default(assigns) do
    ~H"""
    <%= if @post != nil do %>
    <div id={@post.title} class="w-full my-6 rounded-md shadow bg-white dark:bg-gray-800 overflow-x-hidden">
      <div class="pt-4 p-3 flex flex-row justify-between items-bottom">
        <div class="flex flex-row items-center justify-start">
            <%= if @rss do %>

              <img class="w-12" src={@post.source.icon} onerror="this.src='/images/rss.png'"/>

              <p class="font-bold text-lg pl-2">
                <%= if @user_link do %>
                  <%= live_redirect @post.author, to: live_path(Endpoint, Live.Source, @post.source) %>
                <% else %>
                  <%= @post.author %>
                <% end %>

                <i class="block text-sm text-gray-400">@external</i>
              </p>

            <% else %>

              <% username = Nindo.Accounts.get(@post.author_id).username %>

              <img class="w-12 object-cover h-12 rounded-full border border-indigo-700 border-2" src={Format.profile_picture(username)}/>
              <p class="font-bold text-lg pl-2">
                <%= if @user_link do %>
                  <a href={"/user/#{username}"}><%= Format.display_name(username) %></a>
                <% else %>
                  <%= Format.display_name(username) %>
                <% end %>
                <i class="block text-sm text-gray-400"><%= "@#{username}" %></i>
              </p>

            <% end %>
          </div>

      </div>
      <hr class="clear-both">

      <%= if @rss do %>

        <%= if @post.source.type == "youtube" and not debug_mode?() do %>
          <% [_, video_id] = String.split(@post.link, "=") %>

          <iframe class="aspect-video w-full" src={YouTube.instance() <> "/embed/#{video_id}"} frameborder="0" allowfullscreen/>
        <% end %>

        <div class="px-3 py-3 text-lg prose prose-headings:font-normal prose-headings:mt-0 prose-headings:mb-2 prose-li:m-0 prose-p:leading-snug dark:prose-invert max-w-none font-roboto"><%=  safe @post.body %></div>
      <% else %>
        <div class="px-3 py-3 text-lg prose prose-headings:font-normal prose-headings:mt-0 prose-headings:mb-2 prose-li:m-0 prose-p:leading-snug dark:prose-invert max-w-none font-roboto"><%= safe markdown @post.body %></div>
      <% end %>

      <p class="px-3 pb-2 italic text-gray-500">Posted on <%= human_datetime(@post.datetime) %></p>
    </div>
    <% end %>
    """
  end

  @doc """
  Post preview. Includes only the title and author, and links to the full post.
  """
  def preview(assigns) do
    ~H"""
      <div class="mb-6">
        <div class="flex flex-row items-center gap-2">
          <%= if @rss do %>

            <img class="w-6" src={@post.source.icon} onerror="this.src='/images/rss.png'"/>

            <p class="font-bold text-lg">
              <%= if @user_link do %>
                <%= live_redirect @post.author, to: live_path(Endpoint, Live.Source, @post.source) %>
              <% else %>
                <%= @post.author %>
              <% end %>
            </p>

          <% else %>

            <% username = Nindo.Accounts.get(@post.author_id).username %>

            <img class="w-6 object-cover h-6 rounded-full border border-indigo-700 border-2" src={Format.profile_picture(username)}/>
            <p class="font-bold text-lg">
              <%= if @user_link do %>
                <%= live_redirect(Format.display_name(username), to: live_path(Endpoint, Live.User, username)) %>
              <% else %>
                <%= Format.display_name(username) %>
              <% end %>
            </p>

          <% end %>
        </div>

        <%= if @rss do %>

          <h3 class="text-xl sm:text-2xl font-medium px-4"><%= live_redirect @post.title, to: live_path(Endpoint, Live.Post, @post.source, @post, @post.title), phx_hook: "ScrollToTop" %></h3>

        <% else %>

          <h3 class="text-xl sm:text-2xl font-medium px-4"><%= live_redirect @post.title, to: live_path(Endpoint, Live.Post, @post.id), phx_hook: "ScrollToTop" %></h3>

        <% end %>

        <%= if @text do %>

          <% <<exerpt::binary-size(250), _rest::binary>> = HtmlSanitizeEx.strip_tags(@post.body) %>

          <p class="text-lg sm:text-xl font-light leading-snug pt-2 px-5">
            <%= exerpt <> "..." %>
          </p>
        <% end %>
      </div>
    """
  end
end
