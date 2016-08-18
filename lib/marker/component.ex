defmodule Marker.Component do
  @moduledoc """
  Marker provides components as a convenient abstraction. Under the hood components define a macro, that can be called just like elements, that calls a hidden template function containing the body of the component. The component macro provides two variables: `content` and `attrs`. `content` contains expressions from the do block and is always a list. `attrs` contains the attributes and is always a map.

    An example makes this all probably much easier to understand, so here are a few components that could make using Bootstrap simpler:

  ```elixir
  defmodule MyComponents do
    use Marker
    import Marker.Component

    component :form_input do
      custom_classes = attrs[:class] || ""
      div class: "form-group" do
        label attrs[:label], for: attrs[:id]
        input id: attrs[:id],
              type: attrs[:type],
              class: "form-control " <> custom_classes
              placeholder: attrs[:placeholder],
              value: attrs[:value]
      end
    end

    component :form_select do
      custom_classes = attrs[:class] || ""
      div class: "form-group" do
        label attrs[:label], for: attrs[:id]
        select content, id: attrs[:id], class: "form-control " <> custom_classes
      end
    end

    def test do
      html body do
        form do
          form_input id: "form-address", label: "Address", placeholder: "Fill in address"
          form_select id: "form-country", label: "Country", class: "country-select" do
            option "Netherlands", value: "NL"
            option "Belgium", value: "BE"
            option "Luxembourg", value: "LU"
          end
        end
      end
    end
  end
  ```

    If you want to use components from another module, don't forget to `require` or `import` the module, since components are defined as macros.
  """

  @doc "Define a new component"
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
