defmodule Marker.Compiler do
  alias Marker.Element

  @type element :: String.t | Macro.t | Marker.Element.t
  @type chunks :: [String.t | Macro.t]

  # API

  @spec compile(Marker.content, Macro.Env.t) :: { :safe, String.t } | Macro.t
  def compile(content, env) do
    compile(content, env, []) |> to_result()
  end

  @spec escape(String.t) :: String.t
  def escape(string) do
    escape(string, "")
  end

  # Content parsing

  @spec compile(Marker.content, Macro.Env.t, chunks) :: chunks
  defp compile(content, env, chunks) when is_list(content) do
    Enum.reduce(content, chunks, &compile(&1, env, &2))
  end

  defp compile(content, env, chunks) do
    content
    |> Macro.expand(env)
    |> Marker.Encoder.encode()
    |> compile_element(env, chunks)
  end

  # Element parsing

  @spec compile_element(element, Macro.Env.t, chunks) :: chunks
  defp compile_element(%Element{tag: tag, attrs: attrs, content: content}, env, chunks) do
    chunks = chunks
    |> maybe_doctype(tag)
    |> begin_tag_open(tag)
    |> build_attrs(attrs, env)
    if is_void_element?(tag) do
      void_tag_close(chunks)
    else
      compile(content, env, begin_tag_close(chunks))
      |> end_tag(tag)
    end
  end
  defp compile_element(element, _env, chunks) do
    add_chunk(chunks, element)
  end

  defp begin_tag_open(chunks, tag), do: add_chunk(chunks, "<#{tag}")
  defp begin_tag_close(chunks),     do: add_chunk(chunks, ">")
  defp void_tag_close(chunks),      do: add_chunk(chunks, "/>")
  defp end_tag(chunks, tag),        do: add_chunk(chunks, "</#{tag}>")

  defp maybe_doctype(chunks, :html), do: add_chunk(chunks, "<!doctype html>\n")
  defp maybe_doctype(chunks, _),     do: chunks

  defp is_void_element?(tag) do
    tag in ~w(area base br col embed hr img input keygen link meta param source track wbr)a
  end

  # Attributes parsing

  @spec build_attrs(chunks, Marker.Element.attrs, Macro.Env.t) :: chunks
  defp build_attrs(chunks, attrs, env) when is_list(attrs) do
    Enum.reduce(attrs, chunks, fn
      { _, nil }, chunks   -> chunks
      { _, false }, chunks -> chunks
      { k, true }, chunks  -> enabled_attr(chunks, k)
      { k, v }, chunks     -> attr(chunks, k, v, env)
    end)
  end

  @quote "'"

  @spec attr(chunks, atom, Marker.Encoder.t, Macro.Env.t) :: chunks
  defp attr(chunks, field, value, env) do
    chunks
    |> add_chunk(" #{attr_field(field)}=#{@quote}")
    |> attr_value(value, env)
    |> add_chunk(@quote)
  end

  @spec enabled_attr(chunks, atom) :: chunks
  defp enabled_attr(chunks, field) do
    add_chunk(chunks, " " <> attr_field(field))
  end

  @spec attr_value(chunks, Marker.Encoder.t, Macro.Env.t) :: chunks
  defp attr_value(chunks, value, env) do
    value
    |> Macro.expand(env)
    |> Marker.Encoder.encode()
    |> compile_element(env, chunks)
  end

  defp attr_field(field) do
    case Atom.to_string(field) do
      "_" <> field -> "data-" <> field
      field        -> field
    end
  end

  # Helpers

  entity_map = %{"&" => "&amp;",
                 "<" => "&lt;",
                 ">" => "&gt;",
                 "\"" => "&quot;",
                 "'" => "&#39;"}

  for {char, entity} <- entity_map do
    defp escape(unquote(char) <> rest, acc) do
      escape(rest, acc <> unquote(entity))
    end
  end
  defp escape(<<char::utf8, rest::binary>>, acc) do
    escape(rest, acc <> <<char::utf8>>)
  end
  defp escape("", acc) do
    acc
  end

  defp add_chunk([acc | rest], chunk) when is_binary(chunk) and is_binary(acc) do
    [acc <> chunk | rest]
  end
  defp add_chunk(chunks, chunk) do
    [chunk | chunks]
  end

  defp to_result([string]) when is_binary(string) do
    { :safe, string }
  end
  defp to_result(chunks) do
    {:safe, concat(:lists.reverse(chunks))}
  end

  defp concat(buffer) do
    Enum.reduce(buffer, "", fn
      chunk, acc when is_binary(chunk) ->
        quote do
          unquote(acc) <> unquote(chunk)
        end
      chunk, acc ->
        quote do
          unquote(acc) <> Marker.Encoder.encode(unquote(chunk))
        end
    end)
  end
end
