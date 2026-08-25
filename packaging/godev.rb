# Formula for the augustose/homebrew-godev tap.
#
# This file lives here for review and testing; the published copy belongs in
# the tap repository at Formula/godev.rb. See docs/plans for the rationale.
#
# Before publishing, replace the sha256 with the digest of the release tarball:
#   curl -fsSL https://github.com/augustose/godev/archive/refs/tags/v2.7.0.tar.gz | shasum -a 256
class Godev < Formula
  desc "Navigate 100+ development projects in seconds with fuzzy search"
  homepage "https://github.com/augustose/godev"
  url "https://github.com/augustose/godev/archive/refs/tags/v2.7.0.tar.gz"
  sha256 "REPLACE_WITH_TARBALL_SHA256"
  license "MIT"
  head "https://github.com/augustose/godev.git", branch: "main"

  depends_on "fzf"
  uses_from_macos "zsh"

  def install
    bin.install "godev"
    doc.install "README.md"
  end

  def caveats
    <<~EOS
      godev changes your shell's working directory, which a child process cannot
      do on its own. It needs a small function defined in your shell.

      Set it up once:
        godev --init --install && source ~/.zshrc

      Or add this line to ~/.zshrc yourself:
        eval "$(godev --init zsh)"

      Homebrew-managed installs do not self-update: use `brew upgrade godev`.
    EOS
  end

  test do
    # Catches version drift between the script and the tag it was cut from.
    assert_match "godev version #{version}", shell_output("#{bin}/godev --version")

    # The shell integration must emit a function that points at this binary.
    init = shell_output("#{bin}/godev --init zsh")
    assert_match "godev()", init
    assert_match bin/"godev", init
  end
end
