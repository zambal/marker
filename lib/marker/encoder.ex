defprotocol Marker.Encoder do
  @moduledoc """
  The Marker Encoder protocol.

  This protocol is used by Marker's compiler to convert different Elixir
  data types to it's `Marker.Compiler.element` type.

  Elements can be of the type `String.t`,
  `Marker.Element.t`, or `Macro.t`, so any implementation of the
  `Marker.Encoder` protocol needs to return one of these types.
  Strings are expected to be escaped.

  The following types are implemented by default:

  `Integer`, `Float`, `Atom`, `Tuple`, `BitString` and `Marker.Element`

  You can easily implement a protocol implementation for a custom
  type, by defining an `encode` function that receives the custom type
  and outputs to `Marker.Compiler.element`.

  ### Example

      iex> defmodule Customer do
      ...>   defstruct [:name, :email, :phone]
      ...> end
      iex> defimpl Marker.Encoder, for: Customer do
      ...>   def encode(%Customer{name: name, email: email, phone: phone}) do
      ...>     use Marker.HTML
      ...>
      ...>     div class: "customer" do
      ...>       div [span("name: "), span(name)]
      ...>       div [span("email: "), span(email)]
      ...>       div [span("phone: "), span(phone)]
      ...>     end
      ...>   end
      ...> end
      iex> c = %Customer{name: "Fred", email: "freddy@mail.com", phone: "+31 6 5678 1234"}
      %Customer{email: "freddy@mail.com", name: "Fred", phone: "+31 6 5678 1234"}
      iex> Marker.Encoder.encode c
      {:safe, "<div class='customer'><div><span>name: </span><span>Fred</span></div><div><span>email: </span><span>freddy@mail.com</span></div><div><span>phone: </span><span>+31 6 5678 1234</span></div></div>"}

  """
  @spec encode(Marker.Encoder.t) :: Marker.Compiler.element
  def encode(value)
end

defimpl Marker.Encoder, for: BitString do
  def encode(value), do: Marker.Compiler.escape(value)
end

defimpl Marker.Encoder, for: Marker.Element do
  def encode(value), do: value
end

defimpl Marker.Encoder, for: Tuple do
  def encode({ :safe, value }) when is_binary(value) do
    value
  end
  def encode(value) do
    if Macro.validate(value) == :ok do
      value
    else
      raise Protocol.UndefinedError, protocol: Marker.Encoder, value: value
    end
  end
end

defimpl Marker.Encoder, for: List do
  def encode(list) do
    Enum.reduce(list, "", fn value, acc ->
      acc <> Marker.Encoder.encode(value)
    end)
  end
end

defimpl Marker.Encoder, for: Atom do
  def encode(nil),   do: ""
  def encode(value),  do: Marker.Compiler.escape(Atom.to_string(value))
end

defimpl Marker.Encoder, for: Integer do
  def encode(value), do: Integer.to_string(value)
end

defimpl Marker.Encoder, for: Float do
  def encode(value), do: Float.to_string(value)
end

defimpl Marker.Encoder, for: Date do
  def encode(value), do: Date.to_string(value)
end

defimpl Marker.Encoder, for: DateTime do
  def encode(value), do: DateTime.to_string(value)
end

defimpl Marker.Encoder, for: NaiveDateTime do
  def encode(value), do: NaiveDateTime.to_string(value)
end
