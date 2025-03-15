defmodule Toolscout.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Toolscout.Catalog` context.
  """

  @doc """
  Generate a tool.
  """
  def tool_fixture(attrs \\ %{}) do
    {:ok, tool} =
      attrs
      |> Enum.into(%{
        code: "some code",
        description: "some description",
        image_link: "some image_link",
        name: "some name",
        price: "120.5"
      })
      |> Toolscout.Catalog.create_tool()

    tool
  end
end
