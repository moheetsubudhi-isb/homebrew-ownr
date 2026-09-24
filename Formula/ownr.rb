# Homebrew formula for the ownr CLI.
#
# THIS FILE IS THE ORIGINAL; THE TAP IS A MIRROR OF IT. It is published to
# `moheetsubudhi-isb/homebrew-ownr` as `Formula/ownr.rb`, byte for byte, so
# that `brew install moheetsubudhi-isb/ownr/ownr` serves exactly what this
# repository's test suite holds in step with `pyproject.toml`
# (`tests/test_homebrew_formula.py`, and
# `test_the_tap_serves_this_exact_formula` which re-fetches the published copy).
# Edit it here, run the tests, then copy it over in the same change —
# `README.md` beside this file has the command and the order.
#
# **`brew install` of this formula has still never been run on macOS.** It was
# built and tested on Linuxbrew only (2026-09-13), and it was published to the
# tap on 2026-09-16 with that gap open and recorded rather than hidden: the
# `/cli` page says it in the sentence beside the command, and BUILD_PLAN P8.6
# says which Mac commands close it. If it turns out to be broken on a Mac the
# fix is a commit to the tap, which is why this was judged reversible in a way
# a PyPI version number is not.
#
# Homebrew is the third install path, not the first (D26, D59): `pipx install
# ownr` is the reference install, `uv tool install ownr` sits beside it, and
# brew is a convenience for Mac users who already live in brew. There is no
# `curl | bash` and there will not be one.
class Ownr < Formula
  include Language::Python::Virtualenv

  desc "Know yourself through your computer"
  homepage "https://ownr.digital"
  # Source is the PyPI **sdist**, not this repository. The formula must build
  # the artefact `release.yml` published by Trusted Publishing, so what a Mac
  # user compiles is the bytes PyPI attested to rather than a tarball of a
  # branch. `tests/test_homebrew_formula.py` re-fetches this version's sdist
  # digest from the PyPI JSON API and compares it with the sha256 below.
  url "https://files.pythonhosted.org/packages/1a/ee/431138771bfe4750d4979b312bd3e1874de0e4b6b131d2444a24cb595a56/ownr-0.2.0b8.tar.gz"
  sha256 "924fd4eed63964b2cae24f82b7402626413678527b972cb6ba65efee3bfa5d3d"
  # No `license` stanza. `pyproject.toml` declares no license and the PyPI
  # metadata carries none, so there is nothing true to write here. `brew audit
  # --strict` will flag its absence and that finding is correct: the fix is to
  # decide a license in `pyproject.toml`, not to guess one in the formula.

  # `requires-python` in `pyproject.toml` is `>=3.10`, so the code itself runs
  # on more than this. 3.12 is pinned anyway, and the reason is the resources
  # below rather than the source:
  #
  #   * The resource list was resolved by pip against exactly one interpreter.
  #     Environment markers move with the version — `python_version < "3.11"`
  #     adds `exceptiongroup`, and `typing_extensions` appears and disappears
  #     across the tree for the same reason. A formula whose resources were
  #     resolved on 3.12 but which depends on a floating `python3` installs a
  #     set that nobody ever resolved, on whichever interpreter brew happens to
  #     have linked that week.
  #   * `python@3.12` is current in homebrew-core (3.12.14, bottled, not
  #     deprecated — checked 2026-09-13), so this costs a bottle download and
  #     no compilation.
  #   * `pyobjc`, which the `[mac]` extra needs, has historically been the
  #     slowest dependency here to support a new CPython. Nothing in this
  #     formula installs the extra, but the version people are told to use for
  #     ownr should be one the whole macOS tree is known good on.
  #
  # Moving to `python@3.13` means re-running `brew update-python-resources`
  # against 3.13 in the same commit. Those are one change, never two.
  depends_on "python@3.12"

  # Three of the resources below are Rust extension modules with no pure-Python
  # fallback — `pydantic-core`, `rpds-py` (under `jsonschema`) and
  # `cryptography` (under `mcp`'s `pyjwt[crypto]`). `virtualenv_install_with_
  # resources` builds every resource from its sdist, so unlike `pip install`
  # there is no wheel to fall back on and the toolchain has to be here. Without
  # this line the formula installs fine on a machine that happens to have Rust
  # and fails on a clean Mac, which is the worst of both. Verified by building
  # the whole virtualenv from source on Linux, 2026-09-13.
  depends_on "rust" => :build
  # `cryptography` builds its `_rust` extension against OpenSSL. `python@3.12`
  # already pulls `openssl@3`, but it pulls it as *its own* dependency, which
  # is not a promise to us — naming it here is what keeps the build working if
  # python ever stops needing it. See `install` for why the dependency alone is
  # not sufficient.
  depends_on "openssl@3"

  resource "annotated-types" do
    url "https://files.pythonhosted.org/packages/5f/56/a8120250d128bed162cd73c76d45f6ef9991f3e068f62a8ee060afa3104a/annotated_types-0.8.0.tar.gz"
    sha256 "13b2beaad985e05e2d6407ee4c4f35590b11f8d693a258a561055cac8f64cab7"
  end

  resource "anyio" do
    url "https://files.pythonhosted.org/packages/a9/d2/f4d173e22df740bc37b1db102b386ba719b66e95b0f0d751f556b387e6d2/anyio-4.15.1.tar.gz"
    sha256 "9f28306018cbd6d329e64a36d58256edff76dd996fe423bc957326e578b82a94"
  end

  resource "attrs" do
    url "https://files.pythonhosted.org/packages/9a/8e/82a0fe20a541c03148528be8cac2408564a6c9a0cc7e9171802bc1d26985/attrs-26.1.0.tar.gz"
    sha256 "d03ceb89cb322a8fd706d4fb91940737b6642aa36998fe130a9bc96c985eff32"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/a3/c2/24167ea9858356b47a87a50d39908bfdb72ceeefe0041586e704e5376b3a/certifi-2026.7.22.tar.gz"
    sha256 "741e2c3b351ddf169a738da9f2c048608ff7f2c5cc02f1ebc6b118bb090d5d55"
  end

  resource "cffi" do
    url "https://files.pythonhosted.org/packages/9e/ef/008a1939e372c06329a3fce4279c02f328488f3526744906eeec3da7ad5f/cffi-2.1.1.tar.gz"
    sha256 "dd31f52ea1086513bb9df30f8fcee9b8918323ae067a3d5b78bc826a000712be"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/e5/3f/143b048436775b0f76ac3eec145c019e8173ccc2885c8f20319b996d5e83/charset_normalizer-3.5.1.tar.gz"
    sha256 "6117b84ea48435e5356dc737f5121485c30920ba43375fa7b434fd753df0eac3"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/b9/2e/0090cbf739cee7d23781ad4b89a9894a41538e4fcf4c31dcdd705b78eb8b/click-8.1.8.tar.gz"
    sha256 "ed53c9d8990d83c2a27deae68e4ee337473f6330c040a31d4225c9574d16096a"
  end

  resource "cryptography" do
    url "https://files.pythonhosted.org/packages/bb/ad/5d6702db60b1e40b41ef513b6967ff5848f307d50f8449baf1634f5908f1/cryptography-50.0.1.tar.gz"
    sha256 "5dd9bda1c12b4162f6ff568eeb5e0ff956c28d14406e875cfe8a63a2d414ff20"
  end

  resource "h11" do
    url "https://files.pythonhosted.org/packages/01/ee/02a2c011bdab74c6fb3c75474d40b3052059d95df7e73351460c8588d963/h11-0.16.0.tar.gz"
    sha256 "4e35b956cf45792e4caa5885e69fba00bdbc6ffafbfa020300e549b208ee5ff1"
  end

  resource "httpcore" do
    url "https://files.pythonhosted.org/packages/06/94/82699a10bca87a5556c9c59b5963f2d039dbd239f25bc2a63907a05a14cb/httpcore-1.0.9.tar.gz"
    sha256 "6e34463af53fd2ab5d807f399a9b45ea31c3dfa2276f15a2c3f00afff6e176e8"
  end

  resource "httpx" do
    url "https://files.pythonhosted.org/packages/b1/df/48c586a5fe32a0f01324ee087459e112ebb7224f646c0b5023f5e79e9956/httpx-0.28.1.tar.gz"
    sha256 "75e98c5f16b0f35b567856f597f06ff2270a374470a5c2392242528e3e3e42fc"
  end

  resource "httpx-sse" do
    url "https://files.pythonhosted.org/packages/0f/4c/751061ffa58615a32c31b2d82e8482be8dd4a89154f003147acee90f2be9/httpx_sse-0.4.3.tar.gz"
    sha256 "9b1ed0127459a66014aec3c56bebd93da3c1bc8bb6618c8082039a44889a755d"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/f5/08/8eea9d4b8302028f3abb2c0813953f7aec26d33b7a8960ed760e65ff29fa/idna-3.20.tar.gz"
    sha256 "a7db850025b95ded1eae8a46181a1a6c56c92c96f0e2b005d9ff8dc0210cab44"
  end

  resource "jsonschema" do
    url "https://files.pythonhosted.org/packages/b3/fc/e067678238fa451312d4c62bf6e6cf5ec56375422aee02f9cb5f909b3047/jsonschema-4.26.0.tar.gz"
    sha256 "0c26707e2efad8aa1bfc5b7ce170f3fccc2e4918ff85989ba9ffa9facb2be326"
  end

  resource "jsonschema-specifications" do
    url "https://files.pythonhosted.org/packages/19/74/a633ee74eb36c44aa6d1095e7cc5569bebf04342ee146178e2d36600708b/jsonschema_specifications-2025.9.1.tar.gz"
    sha256 "b540987f239e745613c7a9176f3edb72b832a4ac465cf02712288397832b5e8d"
  end

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/06/ff/7841249c247aa650a76b9ee4bbaeae59370dc8bfd2f6c01f3630c35eb134/markdown_it_py-4.2.0.tar.gz"
    sha256 "04a21681d6fbb623de53f6f364d352309d4094dd4194040a10fd51833e418d49"
  end

  resource "mcp" do
    url "https://files.pythonhosted.org/packages/ba/93/0142dc84a666daf8ad51a34268f34c12fd6fda4f3810c4be2504eecc8212/mcp-1.30.0.tar.gz"
    sha256 "445414625fce5c295faa505bb11bacece661ab6f4028d57c935db57820b7a3e4"
  end

  resource "mdurl" do
    url "https://files.pythonhosted.org/packages/d6/54/cfe61301667036ec958cb99bd3efefba235e65cdeb9c84d24a8293ba1d90/mdurl-0.1.2.tar.gz"
    sha256 "bb413d29f5eea38f31dd4754dd7377d4465116fb207585f97bf925588687c1ba"
  end

  resource "prompt-toolkit" do
    url "https://files.pythonhosted.org/packages/7d/ea/39b988c938f75cb75d7045b5c69f8bfed47ee2152c8837fb403de29d6fb8/prompt_toolkit-3.0.53.tar.gz"
    sha256 "9ec8a0ad96d5c56148b3f914aa79c1564c3fde5d2e6b876e7bc327e353cf8fa6"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/1f/5a/07871137bb752428aa4b659f910b399ba6f291156bdea939be3e96cae7cb/psutil-6.1.1.tar.gz"
    sha256 "cf8496728c18f2d0b45198f06895be52f36611711746b7f30c464b422b50e2f5"
  end

  resource "pycparser" do
    url "https://files.pythonhosted.org/packages/1b/7d/92392ff7815c21062bea51aa7b87d45576f649f16458d78b7cf94b9ab2e6/pycparser-3.0.tar.gz"
    sha256 "600f49d217304a5902ac3c37e1281c9fe94e4d0489de643a9504c5cdfdfc6b29"
  end

  resource "pydantic" do
    url "https://files.pythonhosted.org/packages/53/ef/fc4f868f4e2cee79f863883abffceff107875f569b848507319842d2a681/pydantic-2.13.5.tar.gz"
    sha256 "51a9c5f7b2f8e636f04c6cada605d9b6a3bf1348fdf945a3d8869b19bba0ee08"
  end

  resource "pydantic-core" do
    url "https://files.pythonhosted.org/packages/af/f9/8a06bea35ef8daf588f707784c973a7046e0034c8d8cfb08828eeffb8b75/pydantic_core-2.46.5.tar.gz"
    sha256 "10416c15b8839ecc4ef4d0885da76da6fd0f67333a0eb8aff6d93c4b8f2910fc"
  end

  resource "pydantic-settings" do
    url "https://files.pythonhosted.org/packages/68/ca/31c57507b13119d7d3cfa1576dad2911a4861e3be07b579395f4e9d393f9/pydantic_settings-2.15.0.tar.gz"
    sha256 "694b793e84f766ba76a90ebdefc01d0a9a045dab0382bee70393da93712ad117"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/49/2e/ced460408999b33da6b31b0021b0f37d329e202d4169aeb164493778f25b/pygments-2.21.0.tar.gz"
    sha256 "610ca751c9bc2492b38eb9a38a7fbc93edbbb2d7182edaf34e66ae493dee5c8c"
  end

  resource "pyjwt" do
    url "https://files.pythonhosted.org/packages/02/a5/5197bfd06417837ac079921c66fa6393f1dea3557272a263cebfef69e432/pyjwt-2.15.0.tar.gz"
    sha256 "b11c5f9791d7bf51c2b39a81ed669f6b2dbbd669df2942f6c60167e9e3d1abe4"
  end

  resource "python-dotenv" do
    url "https://files.pythonhosted.org/packages/6a/53/ed9d74092561d4b01a2ef1349d52cdbc135e526c245f366b089cfca6de49/python_dotenv-1.2.3.tar.gz"
    sha256 "a20a594dabeaa385725aa239d5244871c143ecb356add8a20fcf23773a6c3a35"
  end

  resource "python-multipart" do
    url "https://files.pythonhosted.org/packages/5b/42/55c32bb9b12693c092ad250a0e82edb5b31ddeda6eb772de5f308b3804ad/python_multipart-0.0.32.tar.gz"
    sha256 "be54b7f3fa167bb83e4fcd936b887b708f4e57fe75911c02aebf53efaf8d938e"
  end

  resource "referencing" do
    url "https://files.pythonhosted.org/packages/22/f5/df4e9027acead3ecc63e50fe1e36aca1523e1719559c499951bb4b53188f/referencing-0.37.0.tar.gz"
    sha256 "44aefc3142c5b842538163acb373e24cce6632bd54bdb01b21ad5863489f50d8"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/ac/c3/e2a2b89f2d3e2179abd6d00ebd70bff6273f37fb3e0cc209f48b39d00cbf/requests-2.34.2.tar.gz"
    sha256 "f288924cae4e29463698d6d60bc6a4da69c89185ad1e0bcc4104f584e960b9ed"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/ab/3a/0316b28d0761c6734d6bc14e770d85506c986c85ffb239e688eeaab2c2bc/rich-13.9.4.tar.gz"
    sha256 "439594978a49a09530cff7ebc4b5c7103ef57baf48d5ea3184f21d9a2befa098"
  end

  resource "rpds-py" do
    url "https://files.pythonhosted.org/packages/aa/2a/9618a122aeb2a169a28b03889a2995fe297588964333d4a7d67bdf46e147/rpds_py-2026.6.3.tar.gz"
    sha256 "1cebd1337c242e4ec2293e541f712b2da849b29f48f0c293684b71c0632625d4"
  end

  resource "schedule" do
    url "https://files.pythonhosted.org/packages/0c/91/b525790063015759f34447d4cf9d2ccb52cdee0f1dd6ff8764e863bcb74c/schedule-1.2.2.tar.gz"
    sha256 "15fe9c75fe5fd9b9627f3f19cc0ef1420508f9f9a46f45cd0769ef75ede5f0b7"
  end

  resource "shellingham" do
    url "https://files.pythonhosted.org/packages/58/15/8b3609fd3830ef7b27b655beb4b4e9c62313a4e8da8c676e142cc210d58e/shellingham-1.5.4.tar.gz"
    sha256 "8dbca0739d487e5bd35ab3ca4b36e11c4078f3a234bfce294b0a0291363404de"
  end

  resource "sse-starlette" do
    url "https://files.pythonhosted.org/packages/2b/54/6767bb789b2f2fed6e0f953df949cd39dc263a384c1b65a95232598621d6/sse_starlette-3.4.11.tar.gz"
    sha256 "1bae716c02f3e6f294be41ff333220692dae7c3cbab077c900f159676719dade"
  end

  resource "starlette" do
    url "https://files.pythonhosted.org/packages/c4/68/79977123bb7be889ad680d79a40f339082c1978b5cfcf62c2d8d196873ac/starlette-0.52.1.tar.gz"
    sha256 "834edd1b0a23167694292e94f597773bc3f89f362be6effee198165a35d62933"
  end

  resource "typer" do
    url "https://files.pythonhosted.org/packages/c5/58/a79003b91ac2c6890fc5d90145c662fd5771c6f11447f116b63300436bc9/typer-0.12.5.tar.gz"
    sha256 "f592f089bedcc8ec1b974125d64851029c3b1af145f04aca64d69410f0c9b722"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/f6/cc/6253133b5bb138fc3306cebfbda2c520f545d36b5be2c7255cc528bb45d6/typing_extensions-4.16.0.tar.gz"
    sha256 "dc983d19a509c94dba722ee6abd33940f7c05a89e243c47e907eb4db6f1a43e5"
  end

  resource "typing-inspection" do
    url "https://files.pythonhosted.org/packages/a3/26/b09b8010994eccc3c09092e6b34058f36a460eea2d4c3e8b910c695975a0/typing_inspection-0.4.4.tar.gz"
    sha256 "547274fa6b0a561ccf549cc9524b999a578e737d015d8709d021f9d0d13bea47"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/e3/05/b17359e1cefb4f909b5e40b1b90a496d987258916dbbf88e842c729f510e/urllib3-2.8.0.tar.gz"
    sha256 "63bf2ead4c879426ebf22ef2a781eeb4aa3b4ae798a0435506f8687fd5bb9b63"
  end

  resource "uvicorn" do
    url "https://files.pythonhosted.org/packages/5d/ad/04bbb797c84fc1f26cb171f7394716f4865ffb8d8c5e1eef42565c2dfa6b/uvicorn-0.53.0.tar.gz"
    sha256 "a9356f0cb89b3b8621529c5d5eebd69bfe154f4c3f68b4cf2de47e45fa855c2e"
  end

  resource "wcwidth" do
    url "https://files.pythonhosted.org/packages/dc/ac/3a943d2792c9bb368aaa8b50121c0f778460ba2d7fbdc0a0366201d9e761/wcwidth-0.9.1.tar.gz"
    sha256 "5823209b0d43af322ce698c689380d7c15ca31fa8e6e3be8459f27031bef0af5"
  end

  def install
    # Without these two lines the build dies in `openssl-sys`'s build script
    # with "Could not find directory of OpenSSL installation", and it dies
    # *after* compiling rust, pydantic-core and rpds-py — about ten minutes in.
    # Homebrew's `openssl@3` is keg-only, so it is not on any default search
    # path, and `cryptography`'s Rust crate looks at `OPENSSL_DIR` and nowhere
    # else. `depends_on "openssl@3"` guarantees the library is installed; it
    # guarantees nothing about the build finding it.
    #
    # `OPENSSL_NO_VENDOR` is the belt to that brace: without it `openssl-sys`
    # is free to fall back to compiling its own vendored copy, which would
    # "work" and silently produce an ownr linked against an OpenSSL that
    # Homebrew does not patch or update.
    #
    # Found by running `brew install --build-from-source` on Linux,
    # 2026-09-13. It is not a Linux-only problem: `openssl@3` is keg-only on
    # macOS too and macOS ships no usable OpenSSL headers of its own.
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix
    ENV["OPENSSL_NO_VENDOR"] = "1"
    virtualenv_install_with_resources
  end

  # `brew services start ownr` as an alternative to the LaunchAgent that
  # `ownr collect` installs. `ownr collect` detects an already-running daemon
  # and does not double-install, so the two cannot both drive a collector.
  #
  # `ownr start --background` is the right command here precisely because it
  # *blocks*: it starts the daemon threads and then sleeps until signalled. It
  # does not fork and it does not detach, which is what launchd and systemd
  # need — a process that daemonises itself looks to launchd like a command
  # that exited the instant it was started, and gets restarted forever.
  service do
    run [opt_bin/"ownr", "start", "--background"]
    # Deliberately NOT `keep_alive true`. `ownr start` exits 1 with "Run ownr
    # setup first." when the config has no `user_id`, and `brew install ownr &&
    # brew services start ownr` before ever running `ownr setup` is an ordering
    # people actually follow. Under `keep_alive` that becomes a respawn loop
    # writing the same line into the log every ten seconds forever. Failing
    # once and staying stopped is the honest behaviour: `brew services info
    # ownr` then reports it stopped, which is true, and the person reads the
    # log line that tells them what to run.
    keep_alive false
    log_path var/"log/ownr.log"
    error_log_path var/"log/ownr.log"
  end

  test do
    # `--help` is the whole test on purpose. It proves the virtualenv linked,
    # that the console-script shim resolves, and that `ownr/cli.py` imports —
    # which is the failure worth catching here, because the CLI imports `typer`,
    # `click`, `rich` and `psutil` at module scope, so a missing or
    # mis-resolved resource above surfaces in this test rather than on a
    # stranger's machine. Anything further (`ownr setup`, `ownr collect`)
    # writes into the invoking user's home directory and reaches the network,
    # and a formula test must do neither.
    assert_match "Usage", shell_output("#{bin}/ownr --help")
  end
end
