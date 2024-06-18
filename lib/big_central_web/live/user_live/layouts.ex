defmodule BigCentralWeb.UserLive.Layouts do
  use BigCentralWeb, :live_view

  alias Bfsp.Biscuit
  alias BigCentral.Repo
  import Ecto.Query

  def auth_header(%{token: token} = assigns) when not is_nil(token) do
    # TODO don't check email, use token and lookup
    # TODO generate a new token that just allows payment
    {:ok, user_id} =
      Biscuit.get_user_id(
        token,
        Biscuit.public_key_from_private(System.get_env("TOKEN_PRIVATE_KEY"))
      )

    query = from(u in BigCentral.Users.User, where: u.id == ^user_id, select: u.email)
    email = Repo.one(query)
    assigns = assign(assigns, email: email)

    ~H'''
    <ul class="relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
      <li class="text-[0.8125rem] leading-6 text-zinc-900">
        <%= @email %>
      </li>
      <li>
        <.link
          href="/files"
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          Files
        </.link>
      </li>

      <li>
        <.link
          href={System.get_env("BIG_MONEY_URL") <> "/subscription?token=" <> @token}
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          Subscription
        </.link>
      </li>

      <li>
        <.link
          href="/users/logout"
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          Log out
        </.link>
      </li>
    </ul>
    '''
  end

  def auth_header(assigns) do
    ~H'''
    <ul class="relative z-10 flex items-center gap-4 px-4 sm:px-6 lg:px-8 justify-end">
      <li class="text-[0.8125rem] leading-6 text-zinc-900">
        <.link
          href="/login"
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          Log in
        </.link>
      </li>

      <li class="text-[0.8125rem] leading-6 text-zinc-900">
        <.link
          href="/signup"
          class="text-[0.8125rem] leading-6 text-zinc-900 font-semibold hover:text-zinc-700"
        >
          Sign up
        </.link>
      </li>
    </ul>
    '''
  end

  embed_templates "layouts/*"
end
