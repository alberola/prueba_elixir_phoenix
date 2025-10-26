defmodule PruebaElixirPhoenixWeb.ApiMetereologicaLive do
  use PruebaElixirPhoenixWeb, :live_view
  alias PruebaElixirPhoenix.ApiMetereologica

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:ciudad, "")
     |> assign(:datos, nil)
     |> assign(:error, nil)
     |> assign(:cargando, false)}
  end

  @impl true
  def handle_event("buscar", %{"ciudad" => ciudad}, socket) do
    send(self(), {:buscar_ciudad, ciudad})
    {:noreply, assign(socket, cargando: true, error: nil, datos: nil)}
  end

  @impl true
  def handle_info({:buscar_ciudad, ciudad}, socket) do
    case ApiMetereologica.obtener_por_ciudad(ciudad) do
      {:ok, datos} ->
        {:noreply,
         socket
         |> assign(:ciudad, ciudad)
         |> assign(:datos, datos)
         |> assign(:error, nil)
         |> assign(:cargando, false)}

      {:error, _} ->
        {:noreply,
         socket
         |> assign(:ciudad, ciudad)
         |> assign(:datos, nil)
         |> assign(:error, "No se encontraron datos para la ciudad especificada.")
         |> assign(:cargando, false)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-xl p-6 space-y-6">
      <h1 class="text-2xl font-bold text-center mb-4">🌦️ API Meteorológica (Open-Meteo)</h1>

      <form phx-submit="buscar" class="flex gap-2">
        <input
          name="ciudad"
          value={@ciudad}
          placeholder="Alicante"
          class="border px-3 py-2 grow rounded"
        />
        <button class="bg-blue-400 text-white px-4 py-2 rounded">Buscar</button>
      </form>

      <%= if @cargando do %>
        <div class="text-center text-gray-600 mt-4 animate-pulse">
          Cargando datos meteorológicos...
        </div>
      <% end %>

      <%= if @error do %>
        <div class="text-red-600 mt-4 text-center"><%= @error %></div>
      <% end %>

      <%= if @datos do %>
        <div class="border rounded-lg p-5 mt-6 shadow-md bg-gray-50">
          <h2 class="text-lg font-semibold mb-2 text-center text-black">
            <%= @datos.ubicacion %>
          </h2>

          <div class="flex flex-col items-center space-y-2 text-center">
            <div class="text-5xl font-bold text-black">
              <%= @datos.actual["temperature"] %>°C
            </div>
            <div class="text-gray-700">
              Viento: <%= @datos.actual["windspeed"] %> km/h<br/>
              Dirección: <%= @datos.actual["winddirection"] %>°
            </div>
            <div class="text-gray-600 text-sm mt-2">
              Última actualización: <%= @datos.actual["time"] %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
