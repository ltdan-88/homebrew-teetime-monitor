class TeetimeMonitor < Formula
  desc "Local TUI for monitoring a pc caddie golf club's tee sheet"
  homepage "https://github.com/ltdan-88/teetime-monitor"
  url "https://github.com/ltdan-88/teetime-monitor/archive/refs/tags/v1.0.0rc4.tar.gz"
  sha256 "8a62abb6ad1b7c82036c694fc96759e92bfd0e0b64427722f1be4c0e2022842c"
  license "MIT"

  depends_on "python@3.12"

  # A plain venv + full `pip install .` (not Language::Python::Virtualenv's pip_install_and_link, which
  # passes --no-deps and wants every dependency as a vendored `resource`): the usual tradeoff for a
  # personal tap with a real Python application.
  def install
    system formula_opt_bin("python@3.12")/"python3.12", "-m", "venv", libexec
    system libexec/"bin/pip", "install", "--upgrade", "pip"
    system libexec/"bin/pip", "install", buildpath
    bin.install_symlink libexec/"bin/teetime-monitor"
    # The unattended scraper a launchd agent can run (see the README).
    bin.install_symlink libexec/"bin/teetime-monitor-scrape"
    # The browser version: opens the Overview in a local browser window.
    bin.install_symlink libexec/"bin/teetime-monitor-web"
  end

  def caveats
    <<~EOS
      Start it:
        teetime-monitor          in the terminal
        teetime-monitor-web      in your browser

      Your settings and the collected tee times live in two fixed places, so it works from any folder:
        ~/.config/teetime-monitor/        clubs, login, preferences
        ~/.local/share/teetime-monitor/   scrape history

      The step-by-step setup is in the README:
        https://github.com/ltdan-88/teetime-monitor#readme
    EOS
  end

  test do
    system libexec/"bin/python", "-c", "from src import tui"
    assert_match version.to_s, shell_output("#{bin}/teetime-monitor --version")
  end
end
