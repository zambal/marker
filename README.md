# Marker

  `Marker` strives to be the most convenient tool for writing html markup in Elixir. It allows writing markup with Elixir syntax, while reaching the performance of precompiled templates.

  Here's an example to give you an idea how `Marker` looks:

```elixir
use Marker.HTML

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

  `Marker` escapes all strings by default. In order to prevent an already escaped result from being escaped again when passed as an argument to another element, compiled results are wrapped in a `{:safe, ...}` tuple to mark the result as escaped. The Phoenix framework uses this idiom too. Besides escaping strings, `Marker` provides the `Marker.Encoder` protocol for encoding terms to one of Markers internal data types. See the protocol documentation for more info.

  `Marker` is very flexible with the arguments you can pass to its element macro's:

```elixir
iex> use Marker.HTML
...> Marker.HTML
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

## Templates and Components

  `Marker` provides templates and components as a convenient abstraction. A template is just a function with one argument. It expects a data structure that can be accessed with the `Access` protocol, like `Map` or `Keyword`. The fields of the argument can be accessed with the `@` attribute syntax. This works because templates and components provide an implementation of the `assigns` extension of `EEx` templates for easy data access. Components are like templates, but in adition to the template function, they define a macro that can be called just like the element macros. The contents of the `do` block of a component are accessable as `@__content__` in the component definition and is always wrapped in a list. A small, but important difference between templates and components is that an unavailable assign in a template raises a `RuntimeError`, as assigns are considered mandatory for templates, but they are optional for components. This makes it for example possible to define a component that optionally accepts a custom class.

  An example makes this all probably much easier to understand, so here are a few components that could make using Bootstrap simpler:

```elixir
defmodule MyComponents do
  use Marker

  component :form_input do
    custom_classes = @class || ""
    div class: "form-group" do
      label @label, for: @id
      input id: @id,
            type: @type,
            class: "form-control " <> custom_classes
            placeholder: @placeholder,
            value: @value
    end
  end

  component :form_select do
    custom_classes = @class || ""
    div class: "form-group" do
      label @label, for: @id
      select @__content__, id: @id, class: "form-control " <> custom_classes
    end
  end

  template :test do
    html body do
    h1 @title
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

test title: "My test form"
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
  [{:marker, "~> 2.0"}]
end
```

## Using Marker with the Phoenix framework

  Integrating `Marker` in your Phoenix project is very simple. It even makes working with Phoenix somewhat easier, since you don't need any templates anymore.

  First add `marker` to your dependencies, then add Marker functions and components to your views and call them from the view's render function:

```elixir
defmodule MyProject.PageView do
  use MyProject.Web, :view
  use Marker

  template :greeter do
    div do
      h3 "Hello " <> @name
      p "(from Marker)"
    end
  end

  def render "index.html", assigns do
    greeter name: "World"
  end
end
```

  If you plan to use `Marker` for all your views, you can add the `use Marker` directive to the `<Project>.Web` `__using__` macro, so you don't need to specify these in every view.

## Background

  `Marker` is the successor of [Eml](https://github.com/zambal/eml). While `Eml` has many more features than `Marker`, sometimes less really is more. Apart from writing markup with Elixir syntax, `Eml` also supports parsing of HTML and provides extensive querying capabilities. However, I personally almost never used all these extra features, while writing markup had some unpleasant corner cases, fundamental to `Eml`'s design.

  You could say that where `Eml` is like a swiss army knife, `Marker` tries to do one thing and do it as good as possible.

# License

  Marker is Copyright (C) 2016 by Vincent Siliakus and released under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0.html).
