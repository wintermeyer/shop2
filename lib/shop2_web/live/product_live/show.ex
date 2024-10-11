defmodule Shop2Web.ProductLive.Show do
  use Shop2Web, :live_view

  on_mount {Shop2Web.LiveUserAuth, :live_user_required}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Product <%= @product.id %>
      <:subtitle>This is a product record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/products/#{@product}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit product</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id"><%= @product.id %></:item>

      <:item title="Name"><%= @product.name %></:item>

      <:item title="Description"><%= @product.description %></:item>

      <:item title="Image"><%= @product.image %></:item>

      <:item title="Price"><%= @product.price %></:item>

      <:item title="Quantity stored"><%= @product.quantity_stored %></:item>

      <:item title="Category"><%= @product.category_id %></:item>
    </.list>

    <.back navigate={~p"/products"}>Back to products</.back>

    <.modal
      :if={@live_action == :edit}
      id="product-modal"
      show
      on_cancel={JS.patch(~p"/products/#{@product}")}
    >
      <.live_component
        module={Shop2Web.ProductLive.FormComponent}
        id={@product.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        product={@product}
        patch={~p"/products/#{@product}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:product, Ash.get!(Shop2.Shop.Product, id, actor: socket.assigns.current_user))}
  end

  defp page_title(:show), do: "Show Product"
  defp page_title(:edit), do: "Edit Product"
end
