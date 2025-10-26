defmodule PruebaElixirPhoenix.ApiMetereologica do
  @moduledoc """
  Cliente simple para la API pública de Open-Meteo (sin clave).
  """

  @geocode_url "https://geocoding-api.open-meteo.com/v1/search"
  @forecast_url "https://api.open-meteo.com/v1/forecast"

  # Llama a la API para obtener el tiempo actual según el nombre de ciudad
  def obtener_por_ciudad(ciudad) do
    with {:ok, %{lat: lat, lon: lon, name: name, country: country}} <- geocodificar(ciudad),
         {:ok, datos} <- obtener_tiempo(lat, lon) do
      {:ok, Map.put(datos, :ubicacion, "#{name}, #{country}")}
    else
      _ -> {:error, :no_encontrado}
    end
  end

  defp geocodificar(ciudad) do
    params = [name: ciudad, count: 1, language: "es", format: "json"]

    case Req.get(@geocode_url, params: params) do
      {:ok, %{status: 200, body: %{"results" => [res | _]}}} ->
        {:ok, %{lat: res["latitude"], lon: res["longitude"], name: res["name"], country: res["country"]}}

      _ ->
        {:error, :sin_resultados}
    end
  end

  defp obtener_tiempo(lat, lon) do
    params = [
      latitude: lat,
      longitude: lon,
      current_weather: true,
      timezone: "auto"
    ]

    case Req.get(@forecast_url, params: params) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, %{actual: body["current_weather"]}}

      _ ->
        {:error, :fallo_peticion}
    end
  end
end
