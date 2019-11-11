defmodule OLED.Display.Impl.SSD1306Test do
  use ExUnit.Case, async: true
  alias OLED.DummyDev
  alias OLED.Display.Impl.SSD1306

  test "command/2" do
    state = %SSD1306{
      dev: %DummyDev{}
    }

    assert %SSD1306{} = SSD1306.command(state, [1, 2, 3])

    assert_received {:command, 1}
    assert_received {:command, 2}
    assert_received {:command, 3}
  end

  describe "display_frame/2" do
    test "with valid data" do
      state = %SSD1306{
        dev: %DummyDev{},
        width: 96,
        height: 48
      }

      data =
        for _ <- 1..576, into: <<>> do
          <<0>>
        end

      assert %SSD1306{} = SSD1306.display_frame(state, data, memory_mode: :vertical)

      assert_received {:command, 32}
      assert_received {:command, 1}
      assert_received {:transfer, ^data}
      assert_received {:command, 32}
      assert_received {:command, 0}
    end

    test "with invalid data" do
      state = %SSD1306{
        dev: %DummyDev{},
        width: 96,
        height: 48
      }

      data =
        for _ <- 1..200, into: <<>> do
          <<0>>
        end

      assert {:error, :invalid_data_size} =
               SSD1306.display_frame(state, data, memory_mode: :vertical)
    end
  end
end
