defmodule WikiCrawl do

  def main(args) do
    IO.puts "Hello"
    opts = parse_args(args)
    start_page = opts[:start]
    IO.puts "Starting at " <> start_page
    IO.puts visit_link(start_page)
  end

  defp crawl(url, visited) do
    if is_philosophy(url) do
      IO.puts "Found Philosophy page! " <> url
      IO.puts "Here is the path we followed: "
      print_path(visited)
    else
      [next_link visited] = visit_page(url, visited)
      crawl(next_link, visited)
    end
  end


  defp print_path(visited) do
    Enum.map Enum.reverse(visited), fn x -> IO.puts x end
  end

  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [start: :string]
    )
    options
  end

  defp visit_page(url, visited) do
    IO.puts "Visiting " <> url

    if String.starts_with?(url, "/wiki") do
      url = "https://en.wikipedia.org" <> url
    end

    visited = add_link_to_visited(visited, url)
    r = HTTPotion.get url
    r = r.body 

    r
    |> remove_parens 
    |> parse_html 
    |> remove_italics 
    |> remove_tables 
    |> remove_scripts
    |> Floki.find("#mw-content-text") 
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(valid_link?)
    |> hd

    [hd visited]
  end

  defp valid_link?(url, visited) do
    not (
      url in visited or
      String.contains?(url, "#cite_note") or
      String.contains?(url, "redlink=1") or
      String.contains?(url, "action=edit") or
      String.contains?(url, "File:") or
      String.contains?(url, "Special:") or
      String.contains?(url, "Help:") or
      String.contains?(url, "Wiktionary") or
      not String.starts_with?(url, "/wiki")
    )
  end

  defp parse_html(html) do
    Floki.parse(html)
  end

  defp remove_italics(html_tree) do
    Floki.filter_out(html_tree, "i")
  end

  defp remove_tables(html_tree) do
    Floki.filter_out(html_tree, "table")
  end

  defp remove_scripts(html_tree) do
    Floki.filter_out(html_tree, "script")
  end

  defp remove_parens(html_string) do
    Regex.replace(~r/\(.*?\)/, html_string, "")
  end

  defp is_philosophy(url) do
    url.ends_with? "/wiki/Philosophy"
  end

  defp add_link_to_visited(visited, url) do
    [url | visited]
  end

end

# r = HTTPotion.get "https://en.wikipedia.org/wiki/Pooler,_Georgia"
# Floki.find(r.body, ) 