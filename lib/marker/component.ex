defmodule Marker.Component do

  defmacro component(name, do: block) do
    template = String.to_atom(Atom.to_string(name) <> "__template")
    quote do
      defmacro unquote(name)(content_or_attrs \\ nil, maybe_content \\ nil) do
        { attrs, content } = Marker.Element.normalize_args(content_or_attrs, maybe_content)
        attrs = {:%{}, [], attrs}
        template = unquote(template)
        quote do
          unquote(__MODULE__).unquote(template)(unquote(attrs), List.wrap(unquote(content)))
        end
      end
      @doc false
      def unquote(template)(attrs, content) do
        var!(attrs) = attrs; _ = var!(attrs)
        var!(content) = content; _ = var!(content)
        unquote(block)
      end
    end
  end
end
