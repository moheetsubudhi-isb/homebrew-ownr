# homebrew-ownr

The Homebrew tap for the [ownr](https://ownr.digital) CLI.

```sh
brew install moheetsubudhi-isb/ownr/ownr
```

`ownr` is in beta. The formula builds the CLI from the PyPI **sdist** that
ownr's release workflow published by Trusted Publishing, in its own virtualenv
against `python@3.12`.

**Known gap, stated rather than hidden:** the formula was generated with
`brew update-python-resources` and built and tested with
`brew install --build-from-source` and `brew test` on **Linuxbrew**, not on
macOS. A macOS install has not yet been run end to end, and neither has
`brew services start ownr`. If it fails on your Mac, that is a bug worth
reporting, not something you did wrong.

`pipx install ownr` is the reference install on macOS and Linux;
<https://ownr.digital/cli> has it, and this tap is the convenience for people
who already live in brew.

## Where this file comes from

`Formula/ownr.rb` is a byte-identical mirror of `ownr-infra/homebrew/ownr.rb`
in the (private) ownr repository, where a test suite holds it in step with the
package's own metadata — its version, its dependency constraints and the sdist
digest PyPI serves — and where `brew update-python-resources` is re-run to
change the `resource` stanzas. Edits belong there, not here.
