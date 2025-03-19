defmodule Toolscout.CatalogTest do
  use Toolscout.DataCase

  alias Toolscout.Catalog

  describe "tools" do
    alias Toolscout.Catalog.Tool

    import Toolscout.CatalogFixtures

    @invalid_attrs %{name: nil, description: nil, price: nil, image_link: nil}

    test "list_tools/0 returns all tools" do
      tool = tool_fixture()
      assert Catalog.list_tools() == [tool]
    end

    test "get_tool!/1 returns the tool with given id" do
      tool = tool_fixture()
      assert Catalog.get_tool!(tool.id) == tool
    end

    test "create_tool/1 with valid data creates a tool" do
      valid_attrs = %{name: "some name", description: "some description", price: "120.5", image_link: "some image_link"}

      assert {:ok, %Tool{} = tool} = Catalog.create_tool(valid_attrs)
      assert tool.name == "some name"
      assert tool.description == "some description"
      assert tool.price == Decimal.new("120.5")
      assert tool.image_link == "some image_link"
    end

    test "create_tool/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalog.create_tool(@invalid_attrs)
    end

    test "update_tool/2 with valid data updates the tool" do
      tool = tool_fixture()
      update_attrs = %{name: "some updated name", description: "some updated description", price: "456.7", image_link: "some updated image_link"}

      assert {:ok, %Tool{} = tool} = Catalog.update_tool(tool, update_attrs)
      assert tool.name == "some updated name"
      assert tool.description == "some updated description"
      assert tool.price == Decimal.new("456.7")
      assert tool.image_link == "some updated image_link"
    end

    test "update_tool/2 with invalid data returns error changeset" do
      tool = tool_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.update_tool(tool, @invalid_attrs)
      assert tool == Catalog.get_tool!(tool.id)
    end

    test "delete_tool/1 deletes the tool" do
      tool = tool_fixture()
      assert {:ok, %Tool{}} = Catalog.delete_tool(tool)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_tool!(tool.id) end
    end

    test "change_tool/1 returns a tool changeset" do
      tool = tool_fixture()
      assert %Ecto.Changeset{} = Catalog.change_tool(tool)
    end
  end
end
