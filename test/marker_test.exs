defmodule MarkerTest do
  use ExUnit.Case
  doctest Marker

  use Marker.HTML
  import Marker, only: [component: 2]

  component :form_input do
    custom_classes = @class || ""

    div class: "form-group" do
      label(@label, for: @id)

      input(
        id: @id,
        type: @type,
        class: "form-control " <> custom_classes,
        placeholder: @placeholder,
        value: @value
      )
    end
  end

  component :form_select do
    custom_classes = @class || ""

    div class: "form-group" do
      label(@label, for: @id)
      select(@__content__, id: @id, class: "form-control " <> custom_classes)
    end
  end

  Marker.template :my_form do
    form class: @class do
      form_input(id: "form-address", label: "Address", placeholder: "Fill in address")

      form_select id: "form-country", label: "Country", class: "country-select" do
        option("Netherlands", value: "NL")
        option("Belgium", value: "BE")
        option("Luxembourg", value: "LU")
      end
    end
  end

  test "components and templates" do
    content = my_form(class: "test")

    assert content ==
             {:safe,
              "<form class='test'><div class='form-group'><label for='form-address'>Address</label><input id='form-address' class='form-control ' placeholder='Fill in address'/></div><div class='form-group'><label for='form-country'>Country</label><select id='form-country' class='form-control country-select'><option value='NL'>Netherlands</option><option value='BE'>Belgium</option><option value='LU'>Luxembourg</option></select></div></form>"}

    assert_raise RuntimeError, fn -> my_form(a: 12) end
  end

  test "calling order" do
    assert div(42) == {:safe, "<div>42</div>"}
    assert div([a: 1], 42) == {:safe, "<div a='1'>42</div>"}
    assert div(42, a: 1) == {:safe, "<div a='1'>42</div>"}
    assert div(do: 42) == {:safe, "<div>42</div>"}
    assert div([a: 1], do: 42) == {:safe, "<div a='1'>42</div>"}

    assert (div do
              42
            end) == {:safe, "<div>42</div>"}

    assert (div a: 1 do
              42
            end) == {:safe, "<div a='1'>42</div>"}
  end

  test "boolean attrs" do
    assert video(autoplay: false) == {:safe, "<video></video>"}
    assert video(autoplay: true) == {:safe, "<video autoplay></video>"}
  end

  test "boolean attr expressions" do
    t = true
    f = false
    assert video(autoplay: f) == {:safe, "<video></video>"}
    assert video(autoplay: t) == {:safe, "<video autoplay></video>"}
  end

  test "nested expressions" do
    name = "Vincent"

    content =
      html do
        head do
          meta(charset: "utf-" <> inspect(8))
        end

        body do
          p("name: " <> name)
          p("age: " <> inspect(2 * 19))
        end
      end

    assert content ==
             {:safe,
              "<!doctype html>\n<html><head><meta charset='utf-8'/></head><body><p>name: Vincent</p><p>age: 38</p></body></html>"}
  end

  test "safe strings" do
    assert h1("Tom & Jerry") == {:safe, "<h1>Tom &amp; Jerry</h1>"}
    assert h1({:safe, "Tom & Jerry"}) == {:safe, "<h1>Tom & Jerry</h1>"}
  end

  test "tag casing" do
    alias Marker.Element, as: E
    assert E.apply_casing(:tag_casing_test, :snake) == :tag_casing_test
    assert E.apply_casing(:tag_casing_test, :snake_upcase) == :TAG_CASING_TEST
    assert E.apply_casing(:tag_casing_test, :pascal) == :TagCasingTest
    assert E.apply_casing(:tag_casing_test, :camel) == :tagCasingTest
    assert E.apply_casing(:tag_casing_test, :lisp) == :"tag-casing-test"
    assert E.apply_casing(:tag_casing_test, :lisp_upcase) == :"TAG-CASING-TEST"
  end
end
