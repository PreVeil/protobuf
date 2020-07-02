defmodule Protobuf.Encoder.DecodeTypeTest do
  use ExUnit.Case, async: true

  alias Protobuf.Encoder
  alias Protobuf.Decoder
  require Logger
  import Protobuf.Decoder

  test "encode_type/2 varint" do
    assert encode(:int32, 42) == <<42>>
  end

  test "encode_type/2 min int32" do
    assert encode(:int32, -2_147_483_648) ==
             <<128, 128, 128, 128, 248, 255, 255, 255, 255, 1>>
  end

  test "encode_type/2 min int64" do
    assert encode(:int64, -9_223_372_036_854_775_808) ==
             <<128, 128, 128, 128, 128, 128, 128, 128, 128, 1>>
  end

  test "encode_type/3 min sint32" do
    assert encode(:sint32, -2_147_483_648) == <<255, 255, 255, 255, 15>>
  end

  test "encode_type/3 max sint32" do
    assert encode(:sint32, 2_147_483_647) == <<254, 255, 255, 255, 15>>
  end

  test "encode_type/3 min sint64" do
    assert encode(:sint64, -9_223_372_036_854_775_808) ==
             <<255, 255, 255, 255, 255, 255, 255, 255, 255, 1>>
  end

  test "encode_type/3 max sint64" do
    assert encode(:sint64, 9_223_372_036_854_775_807) ==
             <<254, 255, 255, 255, 255, 255, 255, 255, 255, 1>>
  end

  test "encode_type/3 bool false" do
    assert encode(:bool, false) == <<0>>
  end

  test "encode_type/3 bool true" do
    assert encode(:bool, true) == <<1>>
  end

  test "encode_type/3 a fixed64" do
    assert encode(:fixed64, 8_446_744_073_709_551_615) ==
             <<255, 255, 23, 118, 251, 220, 56, 117>>
  end

  test "encode_type/3 max fixed64" do
    assert encode(:fixed64, 18_446_744_073_709_551_615) ==
             <<255, 255, 255, 255, 255, 255, 255, 255>>
  end

  test "encode_type/3 min sfixed64" do
    assert encode(:sfixed64, -9_223_372_036_854_775_808) ==
             <<0, 0, 0, 0, 0, 0, 0, 128>>
  end

  test "encode_type/3 max sfixed64" do
    assert encode(:sfixed64, 9_223_372_036_854_775_807) ==
             <<255, 255, 255, 255, 255, 255, 255, 127>>
  end

  test "encode_type/3 min double" do
    assert encode(:double, 5.0e-324) == <<1, 0, 0, 0, 0, 0, 0, 0>>
  end

  test "encode_type/3 max double" do
    assert encode(:double, 1.7976931348623157e308) ==
             <<255, 255, 255, 255, 255, 255, 239, 127>>
  end

  test "encode_type/3 int as double" do
    assert encode(:double, -9_223_372_036_854_775_808) ==
             <<0, 0, 0, 0, 0, 0, 224, 195>>
  end

  test "encode_type/3 string" do
    assert encode(:string, "testing") == <<7, 116, 101, 115, 116, 105, 110, 103>>
  end

  test "encode_type/3 bytes" do
    assert encode(:bytes, <<42, 43, 44, 45>>) == <<4, 42, 43, 44, 45>>
  end

  test "encode_type/3 fixed32" do
    assert encode(:fixed32, 4_294_967_295) == <<255, 255, 255, 255>>
  end

  test "encode_type/3 sfixed32" do
    assert encode(:sfixed32, 2_147_483_647) == <<255, 255, 255, 127>>
  end

  test "encode_type/3 float" do
    assert encode(:float, 3.4028234663852886e38) == <<255, 255, 127, 127>>
  end

  test "encode_type/3 int as float" do
    assert encode(:float, 3) == <<0, 0, 64, 64>>
  end

  test "encode_type/3 float infinity/-infinity/nan" do
    Enum.each([:infinity, :negative_infinity, :nan], fn f ->
      bin = encode(:float, f)
      assert f == Decoder.decode_type_m(:float, :fake, bin)
    end)
  end

  test "encode_type/3 double infinity/-infinity/nan" do
    Enum.each([:infinity, :negative_infinity, :nan], fn f ->
      bin = encode(:double, f)
      assert f == Decoder.decode_type_m(:double, :fake, bin)
    end)
  end

  test "encode_type/2 wrong uint32" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:uint32, 12_345_678_901_234_567_890)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:uint32, -1)
    end
  end

  test "encode_type/2 wrong uint64" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:uint64, 184_467_440_737_095_516_150)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:uint64, -1)
    end
  end

  test "encode_type/2 wrong fixed32" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:fixed32, 12_345_678_901_234_567_890)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:fixed32, -1)
    end
  end

  test "encode_type/2 wrong fixed64" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:fixed64, 184_467_440_737_095_516_150)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:fixed64, -1)
    end
  end

  test "encode_type/2 wrong int32" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:int32, 2_147_483_648)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:int32, -2_147_483_649)
    end
  end

  test "encode_type/2 wrong int64" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:int64, 184_467_440_737_095_516_150)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:int64, -184_467_440_737_095_516_150)
    end
  end

  test "encode_type/2 wrong sint32" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:sint32, 2_147_483_648)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:sint32, -2_147_483_649)
    end
  end

  test "encode_type/2 wrong sint64" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:sint64, 184_467_440_737_095_516_150)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:sint64, -184_467_440_737_095_516_150)
    end
  end

  test "encode_type/2 wrong sfixed32" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:sfixed32, 2_147_483_648)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:sfixed32, -2_147_483_649)
    end
  end

  test "encode_type/2 wrong sfixed64" do
    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:sfixed64, 184_467_440_737_095_516_150)
    end

    assert_raise Protobuf.TypeEncodeError, fn ->
      encode(:sfixed64, -184_467_440_737_095_516_150)
    end
  end

  defp encode(type, value) do
    type
    |> Encoder.encode_type(value)
    |> IO.iodata_to_binary()
  end
end
