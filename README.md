# website_dot_org

Your website is a directory of `.org` files. `website_dot_org` turns it into
static HTML with pandoc: every page gets a terminal-style header listing the
directory it lives in (`ls -a`), so visitors browse the site like a filesystem.

## Rules

| In the source tree            | On the site                                              |
|-------------------------------|----------------------------------------------------------|
| `page.org`                    | `page.html`, listed in the nav as `page.org`             |
| `dir/index.org`               | the page for `dir/`; without one, a nav-only index       |
| subdirectory with `.org` files| nav entry `dir` (and its own pages, recursively)         |
| `LINK_name` (URL on line 1)   | nav entry `name` pointing at the URL                     |
| symlink to `https://…`        | nav entry pointing at the URL                            |
| git submodule with README.org | one page, `sub/README.html`, under the parent's nav       |
| anything else                 | copied as-is (images, PDFs, `CNAME`, `typography.css`)   |

Hidden files and directories are ignored. Math (`$x$`, `\[…\]`) renders with KaTeX.
A page with `#+DRAFT: t` isn't rendered or listed (cards show it greyed out).

Org only captions images and tables. For other figures (display math, a table
with its caption below) use a figure block:

```org
#+begin_figure
\[x^2 + y^2 = 1\]
#+begin_figcaption
The unit circle.
#+end_figcaption
#+end_figure
```

## Cards

`NAV_STYLE=cards` swaps the terminal nav bar for a site bar (`SITE_LOGO` +
`SITE_TITLE`, linking home), and every index page lists its entries as a grid
of picture cards below its content. A card's label and picture come from the
entry's org file (`dir/index.org` for a directory):

```org
#+CARD_TITLE: 1: Bits, How a Computer Works   (default: #+TITLE, else the name)
#+CARD_IMAGE: ../images/1.svg                 (relative to the org file)
```

Card styles (`.wdo-bar`, `.wdo-cards`, `.wdo-card`, `.wdo-card-img`,
`.wdo-card-label`, `.wdo-draft`) can be overridden in your `typography.css`.

Each build writes a content hash to `version.txt` and into every page. Pages
check it on load and reload themselves when a newer build is deployed, so
visitors don't need a hard refresh (GitHub Pages caches pages for 10 minutes).

## website.conf

Optional, at the site root; it's sourced by bash.

```bash
SITE_HOST=example.org                            # prompt host; default: CNAME, else dir name
NAV_STYLE=terminal                               # terminal (default) or cards
SITE_TITLE="My Site"                             # cards site bar; default: SITE_HOST
SITE_LOGO=logo.svg                               # cards site bar icon, site-root relative
CONTENT_WIDTH=60em                               # max page width, centered; default 60em
declare -A NAV_OVERRIDE=(                        # replace a nav entry: "target|label"
    [cv]="cv/resume.pdf|resume.pdf"              # target is site-root relative or a URL
)
NAV_ORDER=(preface)                              # entry names listed first, in this order
HEAD_INCLUDE=head.html                           # added to every <head>; $root$ = path to site root
EXCLUDE=(README.md "drafts/*")                   # globs relative to the site root
```

## Theme

The image ships a default `typography.css`; put your own at the site root to
replace it.

KaTeX options (macros, `trust`, …) go in `window.katexOptions`, set from a
`<script>` in your `HEAD_INCLUDE`.

## Usage

```sh
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/site" \
    ghcr.io/plumbus-tech/website_dot_org build . build
```

In GitHub Actions (Pages):

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container: ghcr.io/plumbus-tech/website_dot_org:latest
    steps:
      - uses: actions/checkout@v7
        with: { submodules: recursive }
      - run: website_dot_org build . build
      - uses: actions/upload-pages-artifact@v5
        with: { path: build }
  deploy:
    needs: build
    runs-on: ubuntu-latest
    permissions: { pages: write, id-token: write }
    environment: { name: github-pages }
    steps:
      - uses: actions/deploy-pages@v5
```

Without Docker, `bin/website_dot_org build SRC OUT` needs bash and pandoc 3.
