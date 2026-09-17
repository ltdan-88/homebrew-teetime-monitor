class TeetimeMonitor < Formula
  desc "Local TUI for monitoring a pc caddie golf club's tee sheet"
  homepage "https://github.com/ltdan-88/teetime-monitor"
  url "https://github.com/ltdan-88/teetime-monitor/archive/refs/tags/v0.32.0.tar.gz"
  sha256 "24165a9ba4b558b255af9ddce8e38018c9f1f2893ee18cf9cc511af7bf324892"
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
