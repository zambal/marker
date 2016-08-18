defmodule Marker.Element do
  defstruct tag: :div, attrs: %{}, content: nil

  @type attr_name     :: atom
  @type attr_value    :: Marker.Encoder.t
  @type attrs         :: [{attr_name, attr_value}]

  @type t :: %Marker.Element{tag: atom, content: Marker.content, attrs: attrs}

  defmacro __using__(opts) do
    tags = opts[:tags] || []
    casing = opts[:casing] || :snake
    quote do
      defmacro __using__(_) do
        ambiguous_imports = Marker.Element.find_ambiguous_imports(unquote(tags))
        quote do
          import Kernel, except: unquote(ambiguous_imports)
          import unquote(__MODULE__)
        end
      end
      Enum.each(unquote(tags), fn tag ->
        Marker.Element.def_element(tag, unquote(casing))
      end)
    end
  end

  @doc false
  defmacro def_element(tag, casing) do
    quote bind_quoted: [tag: tag, casing: casing] do
      defmacro unquote(tag)(content_or_attrs \\ nil, maybe_content \\ nil) do
        tag = unquote(tag) |> Marker.Element.apply_casing(unquote(casing))
        { attrs, content } = Marker.Element.normalize_args(content_or_attrs, maybe_content)
        %Marker.Element{tag: tag, attrs: attrs, content: content}
        |> Marker.Compiler.compile(__CALLER__)
      end
    end
  end

  @doc false
  def apply_casing(tag, :snake) do
    tag
  end
  def apply_casing(tag, :snake_upcase) do
    tag |> Atom.to_string() |> String.upcase() |> String.to_atom()
  end
  def apply_casing(tag, :pascal) do
    tag |> split() |> Enum.map(&String.capitalize/1) |> join()
  end
  def apply_casing(tag, :camel) do
    [first | rest] = split(tag)
    rest = Enum.map(rest, &String.capitalize/1)
    join([first | rest])
  end
  def apply_casing(tag, :lisp) do
    tag |> split() |> join("-")
  end
  def apply_casing(tag, :lisp_upcase) do
    tag |> split() |> Enum.map(&String.upcase/1) |> join("-")
  end

  defp split(tag) do
    tag |> Atom.to_string() |> String.split("_")
  end

  defp join(tokens, joiner \\ "") do
    tokens |> Enum.join(joiner) |> String.to_atom()
  end

  @doc false
  def find_ambiguous_imports(tags) do
    default_imports = Kernel.__info__(:functions) ++ Kernel.__info__(:macros)
    for { name, arity } <- default_imports, arity in 0..2 and name in tags do
      { name, arity }
    end
  end

  @doc false
  def normalize_args(content_or_attrs, maybe_content) do
    case {content_or_attrs, maybe_content} do
      { [{:do, {:"__block__", _, content}}], nil } -> {[], content}
      { [{:do, content}], nil } -> {[], content}
      { [{_,_}|_] = attrs, nil } -> {attrs, nil}
      { [{_,_}|_] = attrs, [{:do, {:"__block__", _, content}}] } -> {attrs, content}
      { [{_,_}|_] = attrs, [{:do, content}] } -> {attrs, content}
      { [{_,_}|_] = attrs, content } -> {attrs, content}
      { content, nil } -> {[], content}
      { content, [{_,_}|_] = attrs } -> {attrs, content}
      _ ->
        raise ArgumentError, message: "element macro received unexpected arguments"
    end
  end
end
