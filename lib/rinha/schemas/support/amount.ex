defmodule Rinha.Schemas.Support.Amount do
  def to_float(number) do
    number / 100
  end

  def to_integer(number) do
    number
    |> Kernel.*(100)
    |> Float.round(2)
    |> trunc
  end
end
