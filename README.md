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

Each build writes a content hash to `version.txt` and into every page. Pages
check it on load and reload themselves when a newer build is deployed, so
visitors don't need a hard refresh (GitHub Pages caches pages for 10 minutes).

## website.conf

Optional, at the site root; it's sourced by bash.

```bash
SITE_HOST=example.org                            # prompt host; default: CNAME, else dir name
CONTENT_WIDTH=60em                               # max page width, centered; default 60em
declare -A NAV_OVERRIDE=(                        # replace a nav entry: "target|label"
    [cv]="cv/resume.pdf|resume.pdf"              # target is site-root relative or a URL
)
EXCLUDE=(README.md "drafts/*")                   # globs relative to the site root
```

## Theme

The image ships a default `typography.css`; put your own at the site root to
replace it.

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
