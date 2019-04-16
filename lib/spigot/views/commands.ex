defmodule Spigot.Views.Commands do
  use Spigot, :view

  def render("prompt", _assigns) do
    "> "
  end

  def render("unknown", _assigns) do
    "What?\n"
  end
end
