defmodule PlateSlateWeb.Schema.Middleware.ChangesetErrors do
  @behaviour Absinthe.Middleware

  alias Ecto.Changeset

  def call(res, _) do
    with %{errors: [%Changeset{} = changeset]} <- res do
      %{res | value: %{errors: transform_errors(changeset)}, errors: []}
    end
  end

  defp transform_errors(changeset) do
    changeset
    |> Changeset.traverse_errors(&format_error/1)
    |> Enum.map(fn
      {key, value} ->
        %{key: key, message: value}
    end)
  end

  defp format_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
