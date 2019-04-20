defmodule Spigot.Sessions.Auth.OAuth do
  @moduledoc """
  Struct for triggering OAuth
  """

  defstruct [:action, :params]
end

defmodule Spigot.Sessions.Auth do
  @moduledoc """
  Authorization Process

  Handles login
  """

  use GenServer

  alias Spigot.Sessions.Auth.OAuth
  alias Spigot.Conn.Event
  alias Spigot.Grapevine
  alias Spigot.Views.Login

  defstruct [:foreman]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    data = %__MODULE__{foreman: opts[:foreman]}
    {:ok, data}
  end

  @impl true
  def handle_info(:welcome, state) do
    send(state.foreman, {:send, Login.render("welcome", %{})})
    {:noreply, state}
  end

  def handle_info({:recv, ""}, state) do
    {:noreply, state}
  end

  def handle_info({:recv, text}, state) do
    send(state.foreman, {:send, "Thanks for logging in\n"})
    send(state.foreman, {:auth, :logged_in, String.trim(text)})
    {:noreply, state}
  end

  def handle_info(%OAuth{action: :authorization_request, params: params}, state) do
    authorization_request(state, params)
    {:noreply, state}
  end

  def handle_info(%OAuth{action: :authorization_grant, params: params}, state) do
    with {:ok, token} <- Grapevine.authorize(params["code"]),
         {:ok, info} <- Grapevine.info(token["access_token"]) do
      send(state.foreman, {:auth, :logged_in, info["username"]})
    end

    {:noreply, state}
  end

  defp authorization_request(state, %{"host" => "grapevine.haus"}) do
    event = %Event{
      type: :oauth,
      topic: "AuthorizationRequest",
      data: %{
        response_type: "code",
        client_id: Grapevine.client_id(),
        scope: "profile email",
        state: UUID.uuid4(),
        redirect_uri: "urn:ietf:wg:oauth:2.0:oob"
      }
    }
    send(state.foreman, {:send, event})
  end

  defp authorization_request(_state, _params), do: :ok
end
