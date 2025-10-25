defmodule PruebaElixirPhoenixWeb.PageController do
  use PruebaElixirPhoenixWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
