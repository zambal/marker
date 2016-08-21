defmodule Marker do
  @moduledoc File.read! "README.md"

  @type content :: Marker.Encoder.t | [Marker.Encoder.t] | [content]

  @doc "Define a new component"
  defmacro component(name, do: block) do
    template = String.to_atom(Atom.to_string(name) <> "__template")
    block = Marker.handle_assigns(block, true)
    quote do
      defmacro unquote(name)(content_or_attrs \\ nil, maybe_content \\ nil) do
        { attrs, content } = Marker.Element.normalize_args(content_or_attrs, maybe_content)
        content = quote do: List.wrap(unquote(content))
        assigns = {:%{}, [], [{:__content__, content} | attrs]}
        template = unquote(template)
        quote do
          unquote(__MODULE__).unquote(template)(unquote(assigns))
        end
      end
      @doc false
      def unquote(template)(var!(assigns)) do
        use Marker.HTML
        _ = var!(assigns)
        unquote(block)
      end
    end
  end

  @doc "Define a new template"
  defmacro template(name, do: block) do
    block = Marker.handle_assigns(block, false)
    quote do
      def unquote(name)(var!(assigns)) do
        use Marker.HTML
        _ = var!(assigns)
        unquote(block)
      end
    end
  end

  defmacro __using__(_) do
    quote do
      import Marker, only: [component: 2, template: 2]
    end
  end

  @doc false
  def handle_assigns(block, allow_optional) do
    Macro.prewalk(block, fn
      { :@, meta, [{ name, _, atom }]} when is_atom(name) and is_atom(atom) ->
        line = Keyword.get(meta, :line, 0)
        if allow_optional do
          quote line: line do
            Map.get(var!(assigns), unquote(name))
          end
        else
          quote line: line do
            Marker.fetch_assign!(var!(assigns), unquote(name))
          end
        end
      expr ->
        expr
    end)
  end

  @doc false
  def fetch_assign!(assigns, key) do
    case Access.fetch(assigns, key) do
      {:ok, val} ->
        val
      :error ->
        keys = Enum.map(assigns, &elem(&1, 0))
        raise "assign @#{key} not available in Marker template. " <>
          "Please ensure all assigns are given as options. " <>
          "Available assigns: #{inspect keys}"
    end
  end
end
