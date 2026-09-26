class TeetimeMonitor < Formula
  desc "Local TUI for monitoring a pc caddie golf club's tee sheet"
  homepage "https://github.com/ltdan-88/teetime-monitor"
  url "https://github.com/ltdan-88/teetime-monitor/archive/refs/tags/v0.44.1.tar.gz"
  sha256 "79e522b0102721c0d48af3a09d5e8cb6769e11a0164a08baf4ec0aa3b72fe677"
  license "MIT"

  depends_on "python@3.12"
  # No `depends_on xcode:` for `swiftc` (the .app build, below) -- tried first,
  # and reverted for a confirmed reason: Homebrew's own `XcodeRequirement` demands
  # a full Xcode.app install ("A full installation of Xcode.app is required...
  # Installing just the Command Line Tools is not sufficient"), which directly
  # contradicts this project's own verified "Command Line Tools only, no Xcode"
  # rule for the macOS GUI (macos/README.md) -- every build
  # this whole session ran against bare CLT, with no Xcode.app on the machine at
  # all. If `swiftc` genuinely isn't present, the build step below fails on its
  # own with a clear command-not-found error -- an honest failure, not a
  # dependency this formula can correctly express with Homebrew's own DSL.

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
    # The macOS GUI's login (v0.33.0) shells out to this by absolute path
    # the same way it already looks up teetime-monitor-scrape -- needs the same
    # symlink treatment or it's only reachable from inside libexec.
    bin.install_symlink libexec/"bin/teetime-monitor-login"
    # Same reasoning, for the macOS GUI's ad hoc search (v0.34.0).
    bin.install_symlink libexec/"bin/teetime-monitor-search"
    # Same reasoning, for the macOS GUI's add-a-club (v0.35.0).
    bin.install_symlink libexec/"bin/teetime-monitor-directory-refresh"
    bin.install_symlink libexec/"bin/teetime-monitor-add-club"
    # Same reasoning, for the macOS GUI's "browse before saving" (v0.40.0).
    bin.install_symlink libexec/"bin/teetime-monitor-preview-club"
    # Same reasoning, for the macOS GUI's AI provider credentials (v0.43.0).
    bin.install_symlink libexec/"bin/teetime-monitor-ai-login"
    # Same reasoning, for the macOS GUI's Overview recommended pick (v0.44.0).
    bin.install_symlink libexec/"bin/teetime-monitor-picks"

    # The macOS GUI's own .app (v0.36.0; moved from prototypes/macos-swift/ to
    # macos/ in v0.40.0) -- built by the exact same build.sh a source checkout
    # uses directly (see macos/README.md), not a reimplementation of its
    # swiftc/Info.plist/codesign steps here, so the two can't quietly drift
    # apart. It depends on the console
    # scripts symlinked above at fixed paths (see that README's own "isn't
    # standalone" note) -- there's no meaningful order requirement, but it only
    # ever actually works once those exist, which they already do by this point.
    #
    # Placed in the Cellar only, not symlinked into /Applications -- tried, and
    # reverted for a confirmed reason: `install` (and `post_install`, checked the
    # same way) both run inside Homebrew's own build sandbox
    # (formula_installer.rb's `Sandbox.run_or_fork`), which only allow-lists
    # writes under the Cellar/temp/cache -- a real, live `File.symlink` attempt
    # to /Applications from here failed with `Errno::EPERM`, not a guess. There's
    # no per-formula DSL to extend that allow-list (the writable paths are fixed
    # by formula_installer.rb itself, not something `install`'s own code can
    # opt into). `caveats` below prints the one command that does it, to run
    # once outside the sandbox -- the standard way a Formula (as opposed to a
    # Cask, whose whole job is exactly this placement) reaches outside the
    # Cellar for something a plain formula genuinely can't do from `install`.
    system "macos/build.sh"
    cp_r buildpath/"macos/TeetimeMonitor.app", prefix
  end

  def caveats
    <<~EOS
      State lives in two fixed locations, so it works from any directory:
        ~/.config/teetime-monitor/        clubs, login, preferences
        ~/.local/share/teetime-monitor/   scrape history

      Upgrading from before 0.31.0? The first launch copies ./clubs, ./data and
      ./.env across from wherever you used to run it, and says what it moved.

      A native macOS GUI is also installed, inside this formula's own Cellar
      (not /Applications -- Homebrew's build sandbox won't let a plain Formula
      write there, unlike a Cask). Open it directly:
        open #{opt_prefix}/TeetimeMonitor.app
      Or make it appear in Launchpad/Spotlight like a normal app, once:
        ln -sf #{opt_prefix}/TeetimeMonitor.app /Applications/
      It's a companion to the pieces above, not a replacement: it shells out to
      the teetime-monitor-* console scripts this same install just symlinked, so
      it only works alongside them, never on its own.

      See the README for the full setup walkthrough:
        https://github.com/ltdan-88/teetime-monitor#setup
    EOS
  end

  test do
    system libexec/"bin/python", "-c", "from src import tui"
    assert_predicate prefix/"TeetimeMonitor.app/Contents/MacOS/TeetimeMonitor", :executable?
  end
end
