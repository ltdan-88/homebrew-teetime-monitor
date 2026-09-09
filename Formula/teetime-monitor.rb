class TeetimeMonitor < Formula
  include Language::Python::Virtualenv

  desc "Local TUI for monitoring a pc caddie golf club's tee sheet"
  homepage "https://github.com/ltdan-88/teetime-monitor"
  url "https://github.com/ltdan-88/teetime-monitor/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "6205e96421078707de4c5091156cccbd1ecd318dc866c51f0224bbd101b63613"
  license "MIT"

  depends_on "python@3.12"

  # No `resource` blocks for the transitive dependencies below (the usual Homebrew
  # convention) -- this pulls them from PyPI at install time instead. Fine for a
  # personal tap that isn't going through homebrew-core's own reproducibility audit;
  # keeping this formula in sync with pyproject.toml's own dependency list is a lot
  # less upkeep than hand-vendoring a resource stanza per package on every version
  # bump.
  def install
    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install_and_link buildpath
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
        #{libexec}/bin/python -m src.credentials_screen   # sets up .env
        teetime-monitor                                   # first run creates clubs/, data/

      See the README for the full setup walkthrough:
        https://github.com/ltdan-88/teetime-monitor#setup
    EOS
  end

  test do
    system libexec/"bin/python", "-c", "from src import tui"
  end
end
