# Marker

  `Marker` strives to be the most convenient tool for writing html markup in Elixir. It allows writing markup with Elixir syntax, while reaching the performance of precompiled templates.

  Here's an example to give you an idea how `Marker` looks:

    ```elixir
    use Marker

    name = "Vincent"

    html do
      body do
        div do
          h3 "Person"
          p name, class: "name"
          p 2 * 19, class: "age"
        end
      end
    end
    ```

  The above will result in:

    ```elixir
    {:safe,
     "<!doctype html>\n<html><body><div><h3>Person</h3><p class='name'>Vincent</p><p class='age'>38</p></div></body></html>"}
     ```

  `Marker` escapes all strings by default. In order to prevent an already escaped result from being escaped again when passed as an argument to another element, compiled results are wrapped in a `{:safe, ...}` tuple to mark the result as escaped. The Phoenix framework uses this idiom too.

  `Marker` is very flexible with the arguments you can pass to its element macro's:

    ```elixir
    iex> use Marker
    ...> Marker
    iex> div 42
    {:safe, "<div>42</div>"}
    iex> div do: 42
    {:safe, "<div>42</div>"}
    iex> div do
    ...>   42
    ...> end
    {:safe, "<div>42</div>"}
    iex> div class: "test"
    {:safe, "<div class='test'></div>"}
    iex> div [class: "test"], 42
    {:safe, "<div class='test'>42</div>"}
    iex> div 42, class: "test"
    {:safe, "<div class='test'>42</div>"}
    iex> div class: "test" do
    ...>   42
    ...> end
    {:safe, "<div class='test'>42</div>"}

    ```

  You can basicly do anything you like with argument order, as long as attributes are always a `Keyword` literal.

## Components

  `Marker` provides components as a convenient abstraction. Under the hood components define a macro, that can be called just like elements, that calls a hidden template function containing the body of the component. The component macro provides two variables: `content` and `attrs`. `content` contains expressions from the do block and is always a list. `attrs` contains the attributes and is always a map.

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


## Custom elements

  `Marker` also allow you to define custom elements like this:

    ```elixir
    defmodule MyElements do
      use Marker.Element, tags: [:my_element, :another_one]
    end
    ```

  You can now use your custom elements like the default elements:

    ```elixir
    use MyElements

    my_element id: 42 do
      another_one "Hello world"
    end
    ```

  Which will result in:

    ```elixir
    {:safe, "<my_element id='42'><another_one>Hello world</another_one></my_element>"}
    ```

## Installation

  Add `marker` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:marker, "~> 1.0.0"}]
    end
    ```

## Using Marker with the Phoenix framework

  Integrating `Marker` in your Phoenix project is very simple. It even makes working with Phoenix somewhat easier, since you don't need any templates anymore.

  First add `marker` to your dependencies, then add Marker functions and components to your views and call them from the view's render function:

    ```elixir
    defmodule MyProject.PageView do
      use MyProject.Web, :view
      use Marker
      import Marker.Component

      component :greeter do
        div do
          h3 "Hello #{attrs.name}!"
          p "(from Marker)"
        end
      end

      def render "index.html", assigns do
        article do
          greeter name: "World"
        end
      end
    end
    ```

    If you plan to use `Marker` for all your views, you can add the `use Marker` and `import Marker.Component` directives to the `<Project>.Web` `__using__` macro, so you don't need to specify these in every view.

## Background

  `Marker` is the successor of [Eml](https://github.com/zambal/eml). While `Eml` has many more features than `Marker`, sometimes less really is more. Apart from writing markup with Elixir syntax, `Eml` also supports parsing of HTML and provides extensive querying capabilities. However, I personally almost never used all these extra features, while writing markup had some unpleasant corner cases, fundamental to `Eml`'s design.

  You could say that where `Eml` is like a swiss army knife, `Marker` tries to do one thing and do it as good as possible.

# License

  Marker is Copyright (C) 2016 by Vincent Siliakus and released under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0.html).
