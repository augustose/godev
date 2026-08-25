# Publishing godev to Homebrew

**Status: published.** The tap lives at
[augustose/homebrew-godev](https://github.com/augustose/homebrew-godev) and
`brew install augustose/godev/godev` works. What follows is the reference for
future releases.

## 1. Cut the release

The `pre-commit` hook auto-increments the PATCH on every commit that touches
`godev`, but it honours a manually changed `VERSION`. So the bump belongs in the
last commit before the tag, and the tag is cut from that exact commit.

```bash
grep -m1 '^VERSION=' godev          # confirm the intended version
git tag -a v2.8.1 -m "v2.8.1"
git push origin main --tags
gh release create v2.8.1 --title "v2.8.1" --notes "..."
```

The release matters: `_resolve_remote()` prefers GitHub Releases over the branch.

## 2. Compute the tarball sha256

```bash
curl -fsSL https://github.com/augustose/godev/archive/refs/tags/v2.8.1.tar.gz | shasum -a 256
```

## 3. Update the tap

The repository **must** be named `homebrew-godev` for `brew tap augustose/godev`
to resolve.

```bash
git clone https://github.com/augustose/homebrew-godev
cp packaging/godev.rb homebrew-godev/Formula/godev.rb
# replace url and sha256 with the values from steps 1 and 2
```

## 4. Validate before announcing

```bash
brew update
brew upgrade godev          # or: brew install --build-from-source
brew test godev
godev --version             # must match the tag
godev --update              # must redirect to `brew upgrade godev`, downloading nothing
```

## Lessons from the first releases

- **`assert_match` needs a String or Regexp, not a `Pathname`.** `assert_match
  bin/"godev", init` fails with *"Expected #<Pathname:...> to respond to #=~"*.
  Interpolate instead: `assert_match "#{bin}/godev", init`. Only `brew test`
  against a real install catches this — `ruby -c` does not.
- **`brew audit` can break `brew install`.** It silently turns on developer mode
  and builds the vendored gem bundle. On this machine the `json 2.21.2` pinned by
  Homebrew's own `Gemfile.lock` is incompatible with portable-ruby 4.0.6 (which
  ships json 2.18.0 in stdlib), leaving `brew install` and `brew config` broken
  with *"undefined method 'default_sort_keys_proc='"*. Recover by removing the gem:

  ```bash
  B=/opt/homebrew/Library/Homebrew/vendor/bundle/ruby/4.0.0
  rm -rf "$B/gems/json-2.21.2" "$B/extensions/arm64-darwin-20/4.0.0-static/json-2.21.2"
  git -C "$(brew --repository)" config --unset homebrew.devcmdrun
  ```

  For that reason `brew audit` is **not** on the critical validation path.
  `brew install` plus `brew test` are, and they are enough.
- **Watch the `&&` chain when tagging.** `git add` refuses gitignored paths and
  returns non-zero, which skips the commit — but a `git tag` on the next line
  still runs, leaving the tag on the wrong commit. Verify with
  `git log --oneline -1 <tag>` before creating the release.

## Why not homebrew-core

homebrew-core requires notability (~75 stars / 30 forks / 30 watchers) and
maintainer review. A personal tap has no such requirements. Applying to core is
for when the project has traction; the formula is already written to pass
`brew audit --strict`.
