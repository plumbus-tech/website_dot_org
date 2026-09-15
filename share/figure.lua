-- Org only captions images and tables. For any other figure (display math,
-- a table with the caption below it, several blocks) write
--
--   #+begin_figure
--   ...content...
--   #+begin_figcaption
--   ...caption...
--   #+end_figcaption
--   #+end_figure
--
-- and it becomes <figure>...<figcaption>...</figcaption></figure>.
function Div(div)
  if not div.classes:includes('figure') then
    return nil
  end
  local content, caption = pandoc.Blocks({}), pandoc.Blocks({})
  for _, block in ipairs(div.content) do
    if block.t == 'Div' and block.classes:includes('figcaption') then
      caption:extend(block.content)
    else
      content:insert(block)
    end
  end
  if #caption == 1 and caption[1].t == 'Para' then
    caption = pandoc.Blocks({ pandoc.Plain(caption[1].content) })
  end
  div.classes = div.classes:filter(function(c) return c ~= 'figure' end)
  return pandoc.Figure(content, { long = caption }, div.attr)
end
