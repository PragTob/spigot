defmodule Spigot.Command.RouterTest do
  use ExUnit.Case

  alias Spigot.Command.Router

  describe "parsing commands" do
    test "finding the matching pattern" do
      patterns = ["quit", "help", "help :topic"]

      assert {"help", %{}} = Router.parse(patterns, "help ")
      assert {"help :topic", %{"topic" => "topic"}} = Router.parse(patterns, "help topic")
    end
  end
end
