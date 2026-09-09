class TeetimeMonitor < Formula
  desc "Local TUI for monitoring a pc caddie golf club's tee sheet"
  homepage "https://github.com/ltdan-88/teetime-monitor"
  url "https://github.com/ltdan-88/teetime-monitor/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "10305727ea0a3bb149808de18aa235c19f871a2ef50e0038191f5635e3e6247b"
  license "MIT"

  depends_on "python@3.12"

  # Deliberately not Language::Python::Virtualenv's own pip_install_and_link -- that
  # helper always passes pip `--no-deps`, expecting every dependency (playwright,
  # textual, anthropic, pydantic, beautifulsoup4, and their own transitive deps) as
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
  end

  def caveats
    <<~EOS
      teetime-monitor logs into pc caddie itself, which needs a real Chromium
      binary for Playwright -- a one-time download after install:
        #{libexec}/bin/python -m playwright install chromium

      Like `terraform`/`docker-compose`, this reads its own state (saved clubs,
      credentials, scrape history) from whatever directory you run it in, not a
      fixed install location -- pick one directory and always run it from there,
      e.g.:
        mkdir -p ~/teetime-monitor && cd ~/teetime-monitor
        teetime-monitor   # opens on the club browser -- 'r' or 'l' sets up login inline

      See the README for the full setup walkthrough:
        https://github.com/ltdan-88/teetime-monitor#setup
    EOS
  end

  test do
    system libexec/"bin/python", "-c", "from src import tui"
  end
end
