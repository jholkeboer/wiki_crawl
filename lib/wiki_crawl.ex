defmodule WikiCrawl do

  def main(args) do
    IO.puts "Hello"
    opts = parse_args(args)
    start_page = opts[:start]
    IO.puts "Starting at " <> start_page
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [start: :string]
    )
    options
  end

  defp get_link(link) do
    r = HTTPotion.get link
    r.body
  end

  defp parse_html(html, path) do
    Floki.find(html, path)
  end

  defp remove_italics(html_tree) do
    Floki.filter_out(html_tree, "i")
  end

  defp remove_tables(html_tree) do
    Floki.filter_out(html_tree, "table")
  end

  defp remove_parens(html_string) do
    Regex.replace(~r/\(.*?\)/, html_string, "")
  end

  defp is_philosophy(url) do
    url.ends_with? "wikipedia.org/wiki/Philosophy"
  end

  defp add_link_to_list(list, link) do
    [link | list]
  end

end

# r = HTTPotion.get "https://en.wikipedia.org/wiki/Pooler,_Georgia"
# Floki.find(r.body, ) 