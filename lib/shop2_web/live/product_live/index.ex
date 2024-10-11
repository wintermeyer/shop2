defmodule Shop2Web.ProductLive.Index do
  use Shop2Web, :live_view

  on_mount {Shop2Web.LiveUserAuth, :live_user_required}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Products
      <:actions>
        <.link patch={~p"/products/new"}>
          <.button>New Product</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="products"
      rows={@streams.products}
      row_click={fn {_id, product} -> JS.navigate(~p"/products/#{product}") end}
    >
      <:col :let={{_id, product}} label="Id"><%= product.id %></:col>

      <:col :let={{_id, product}} label="Name"><%= product.name %></:col>

      <:col :let={{_id, product}} label="Description"><%= product.description %></:col>

      <:col :let={{_id, product}} label="Image"><%= product.image %></:col>

      <:col :let={{_id, product}} label="Price"><%= product.price %></:col>

      <:col :let={{_id, product}} label="Quantity stored"><%= product.quantity_stored %></:col>

      <:col :let={{_id, product}} label="Category"><%= product.category_id %></:col>

      <:action :let={{_id, product}}>
        <div class="sr-only">
          <.link navigate={~p"/products/#{product}"}>Show</.link>
        </div>

        <.link patch={~p"/products/#{product}/edit"}>Edit</.link>
      </:action>

      <:action :let={{id, product}}>
        <.link
          phx-click={JS.push("delete", value: %{id: product.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="product-modal"
      show
      on_cancel={JS.patch(~p"/products")}
    >
      <.live_component
        module={Shop2Web.ProductLive.FormComponent}
        id={(@product && @product.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        product={@product}
        patch={~p"/products"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    products =
      Ash.read!(Shop2.Shop.Product, actor: socket.assigns[:current_user], load: [:category])

    for product <- products do
      Phoenix.PubSub.subscribe(Shop2.PubSub, "product:updated:#{product.id}")
    end

    {:ok,
     socket
     |> stream(:products, products)
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(
      :product,
      Ash.get!(Shop2.Shop.Product, id, actor: socket.assigns.current_user, load: :category)
    )
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Products")
    |> assign(:product, nil)
  end

  @impl true
  def handle_info({Shop2Web.ProductLive.FormComponent, {:saved, product}}, socket) do
    {:noreply, stream_insert(socket, :products, product)}
  end

  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "product:updated:" <> _product_id,
          payload: %{data: product}
        },
        socket
      ) do
    product = Ash.load!(product, :category, actor: socket.assigns.current_user)
    {:noreply, stream_insert(socket, :products, product)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    product = Ash.get!(Shop2.Shop.Product, id, actor: socket.assigns.current_user)
    Phoenix.PubSub.unsubscribe(Shop2.PubSub, "product:updated:#{product.id}")
    Ash.destroy!(product, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :products, product)}
  end
end
