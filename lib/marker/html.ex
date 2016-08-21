defmodule Marker.HTML do
  @moduledoc """
  All HTML elements are generated in this module.
  To use the element macros outside of components and templates, use `use Marker.HTML` instead of `import Marker.HTML` to import them in to the current scope.
  The `use` macro automatically handles any ambiguities between html elements and the funcions from `Kernel`. `Kernel.div/2` for example is unimported to allow the use of the `div` element.
  If you still need to use `Kernel.div/2`, just call it as `Kernel.div(20, 2)`
  """
  use Marker.Element, tags: ~w(
    a abbr address area article aside audio
    b base bdi bdo blockquote body br button
    canvas caption cite code col colgroup content
    data datalist dd del details dfn div dl dt
    em embed
    fieldset figcaption figure footer form
    h1 h2 h3 h4 h5 h6 head header hr html
    i iframe img input ins
    kbd keygen
    label legend li link
    main map mark menu menuitem meta meter
    nav noscript
    object ol optgroup option output
    p param pre progress
    q
    rp rt ruby
    s samp script section select shadow small source span string style sub summary sup
    table tbody td template textarea tfoot th thead time title tr track
    u ul
    var video
    wbr
    xmp
  )a
end
