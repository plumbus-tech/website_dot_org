-- Turn bare http(s) URLs into links, like Emacs' org export does.
-- Pandoc's org reader leaves them as plain text.
traverse = 'topdown'

function Link(el)
  return el, false -- don't nest links inside existing ones
end

function Str(el)
  local url, trail = el.text:match('^(https?://.-)([.,;:!?)]*)$')
  if url then
    local link = pandoc.Link(url, url)
    if trail ~= '' then
      return {link, pandoc.Str(trail)}
    end
    return link
  end
end
