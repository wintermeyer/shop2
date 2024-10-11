defmodule Shop2Web.ProductLive.FormComponent do
  use Shop2Web, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="product-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" /><.input
          field={@form[:description]}
          type="text"
          label="Description"
        /><.input field={@form[:image]} type="text" label="Image" /><.input
          field={@form[:price]}
          type="text"
          label="Price"
        /><.input field={@form[:quantity_stored]} type="number" label="Quantity stored" />
        <.input
          field={@form[:category]}
          type="text"
          label="Category"
          value={@form.source.source.data.category && @form.source.source.data.category.name}
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Product</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, product_params))}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: product_params) do
      {:ok, product} ->
        notify_parent({:saved, product})

        socket =
          socket
          |> put_flash(:info, "Product #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        IO.inspect(AshPhoenix.Form.errors(form, for_path: :all))
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{product: product}} = socket) do
    form =
      if product do
        AshPhoenix.Form.for_update(product, :update,
          as: "product",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Shop2.Shop.Product, :create,
          as: "product",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
