defmodule MarkerTest do
  use ExUnit.Case
  doctest Marker

  use Marker

  test "calling order" do
    assert div(42) == {:safe, "<div>42</div>"}
    assert div([a: 1], 42) == {:safe, "<div a='1'>42</div>"}
    assert div(42, a: 1) == {:safe, "<div a='1'>42</div>"}
    assert div(do: 42) == {:safe, "<div>42</div>"}
    assert div([a: 1], do: 42) == {:safe, "<div a='1'>42</div>"}
    assert (div do 42 end) == {:safe, "<div>42</div>"}
    assert (div a: 1 do 42 end) == {:safe, "<div a='1'>42</div>"}
  end

  test "boolean attrs" do
    assert (video autoplay: false) == {:safe, "<video></video>"}
    assert (video autoplay: true) == {:safe, "<video autoplay></video>"}
  end

  test "nested expressions" do
    name = "Vincent"
    content = html do
      head do
        meta charset: "utf-" <> inspect(8)
      end
      body do
        p "name: " <> name
        p "age: " <> inspect(2 * 19)
      end
    end

    assert content == {:safe, "<!doctype html>\n<html><head><meta charset='utf-8'/></head><body><p>name: Vincent</p><p>age: 38</p></body></html>"}
  end

  test "safe strings" do
    assert (h1 "Tom & Jerry") == {:safe, "<h1>Tom &amp; Jerry</h1>"}
    assert (h1 {:safe, "Tom & Jerry"}) == {:safe, "<h1>Tom & Jerry</h1>"}
  end

  test "tag casing" do
    alias Marker.Element, as: E
    assert E.apply_casing(:tag_casing_test, :snake)        == :tag_casing_test
    assert E.apply_casing(:tag_casing_test, :snake_upcase) == :TAG_CASING_TEST
    assert E.apply_casing(:tag_casing_test, :pascal)       == :TagCasingTest
    assert E.apply_casing(:tag_casing_test, :camel)        == :tagCasingTest
    assert E.apply_casing(:tag_casing_test, :lisp)         == :"tag-casing-test"
    assert E.apply_casing(:tag_casing_test, :lisp_upcase)  == :"TAG-CASING-TEST"
  end
end
