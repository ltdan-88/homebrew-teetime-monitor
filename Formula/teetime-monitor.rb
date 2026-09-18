class TeetimeMonitor < Formula
  desc "Local TUI for monitoring a pc caddie golf club's tee sheet"
  homepage "https://github.com/ltdan-88/teetime-monitor"
  url "https://github.com/ltdan-88/teetime-monitor/archive/refs/tags/v0.35.0.tar.gz"
  sha256 "413ac074bf29ff1a69c5851fd5944a07d5b5820d3f26ac0e40de2141372d11ac"
  license "MIT"

  depends_on "python@3.12"

  # Deliberately not Language::Python::Virtualenv's own pip_install_and_link -- that
  # helper always passes pip `--no-deps`, expecting every dependency (textual,
  # anthropic, pydantic, beautifulsoup4, and their own transitive deps) as
  # a separately vendored `resource` block, which is the right call for
  # homebrew-core's own reproducibility bar but a lot of upkeep for a personal tap.
  # A plain venv + full `pip install .` instead, pulling straight from PyPI at
  # install time -- the same tradeoff most non-homebrew-core taps make for a real
  # Python application (as opposed to a small pure-Python CLI with few dependencies).
  def install
    system formula_opt_bin("python@3.12")/"python3.12", "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip"
    system libexec/"bin/pip", "install", buildpath
    bin.install_symlink libexec/"bin/teetime-monitor"
    # The unattended scraper the README's launchd agent runs. Without this symlink it
    # only exists inside libexec, and the documented
    # /opt/homebrew/bin/teetime-monitor-scrape path wouldn't resolve at all.
    bin.install_symlink libexec/"bin/teetime-monitor-scrape"
    # The macOS Swift prototype's login (v0.33.0) shells out to this by absolute path
    # the same way it already looks up teetime-monitor-scrape -- needs the same
    # symlink treatment or it's only reachable from inside libexec.
    bin.install_symlink libexec/"bin/teetime-monitor-login"
    # Same reasoning, for the Swift prototype's ad hoc search (v0.34.0).
    bin.install_symlink libexec/"bin/teetime-monitor-search"
    # Same reasoning, for the Swift prototype's add-a-club (v0.35.0).
    bin.install_symlink libexec/"bin/teetime-monitor-directory-refresh"
    bin.install_symlink libexec/"bin/teetime-monitor-add-club"
  end

  def caveats
    <<~EOS
      State lives in two fixed locations, so it works from any directory:
        ~/.config/teetime-monitor/        clubs, login, preferences
        ~/.local/share/teetime-monitor/   scrape history

      Upgrading from before 0.31.0? The first launch copies ./clubs, ./data and
      ./.env across from wherever you used to run it, and says what it moved.

      See the README for the full setup walkthrough:
        https://github.com/ltdan-88/teetime-monitor#setup
    EOS
  end

  test do
    system libexec/"bin/python", "-c", "from src import tui"
  end
end
