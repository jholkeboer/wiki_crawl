defmodule WikiCrawl do

  def main(args) do
    IO.puts "Hello"
    opts = parse_args(args)
    start_page = opts[:start]
    IO.puts "Starting at " <> start_page
    crawl([start_page])
  end

  defp crawl([url | visited]) do
    if is_philosophy(url) do
      IO.puts "Found Philosophy page! " <> url
    else
      visit_page([url | visited]) |> crawl
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

  defp visit_page([url | visited]) do
    valid_link? = fn(url) -> 
      not (
        build_complete_url(url) in visited or
        String.contains?(url, "#cite_note") or
        String.contains?(url, "redlink=1") or
        String.contains?(url, "action=edit") or
        String.contains?(url, "File:") or
        String.contains?(url, "Special:") or
        String.contains?(url, "Help:") or
        String.contains?(url, "Wiktionary") or
        String.contains?(url, "Wikipedia:") or
        not String.starts_with?(url, "/wiki")
      )
    end

    link = build_complete_url(url)

    visited = add_link_to_visited(visited, link)

    IO.puts "Visited so far:"
    print_path(visited)
    IO.puts ""    


    IO.puts "Visiting " <> url

    r = HTTPotion.get link, [follow_redirects: true]
    r = r.body 

    next = (r
    |> remove_parens 
    |> parse_html 
    |> remove_italics 
    |> remove_tables 
    |> remove_scripts
    |> Floki.find("#mw-content-text") 
    |> Floki.find("a")
    |> Floki.attribute("href")
    |> Enum.filter(valid_link?)
    |> hd)

    [next | visited]
  end

  defp parse_html(html) do
    Floki.parse(html)
  end

  def build_complete_url(url) do
    link = cond do
      String.starts_with?(url, "/wiki") -> "https://en.wikipedia.org" <> url
      true -> url
    end
    cond do
      String.contains?(link, "#") -> String.split(link, "#") |> hd
      true -> link
    end
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
    String.ends_with?(url, "/wiki/Philosophy")
  end

  defp add_link_to_visited(visited, url) do
    [url | visited]
  end

end
