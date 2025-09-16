### Questions about LibreELEC?

To get your questions answered, please ask in the LibreELEC [Forum], on IRC: 
\#libreelec on Libera.Chat. 

Do not open an issue.

### Issue Reports

**BEFORE you report a bug make sure you got the latest testing version of 
LibreELEC. Your bug might be already fixed.**

If you are at all unsure whether it's a bug in LibreELEC or a problem with 
something else, post in the LibreELEC [Forum] instead. If it turns out that it is
a bug, an issue can always be opened later.

If you are sure that it's a bug in LibreELEC and you have not found a [similar issue], open a new [issue]
and try to answer the following questions:
- What did you do?
- What did you expect to happen?
- What happened instead?

**It is also importent to provide logs for debugging.
A zip file can be found in the [logfiles] samba share, this will contain all the logs needed.**

Make sure to specify which version of LibreELEC you are using.
- LibreELEC version
- LibreELEC build
- LibreELEC arch

Please don't paste log messages in the issue reports or issue comments - use 
[sprunge.us](http://sprunge.us) instead.

Feature requests are great, but they usually end up lying around the issue
tracker indefinitely. Sending a pull request is a much better way of getting a
particular feature into LibreELEC.

Please dont ask us to add 3rdparty drivers unless you are the maintainer/developer of the driver,
we have no manpower to support a non-mainlined kernel driver for your hardware.
However, LibreELEC comes with minimal set of kernel drivers enabled, if you are sure that your hardware
is supported in mainline kernel, feel free to send us a Pull Request to enable it in our
kernel defconfigs. We are always happy to support known-working hardware.

### Reporting build failures

As buildsystem / core packages (toolchain) / random libraries change from time to time, it is required
that you always do a clean build (make clean) before reporting build failures. Also make sure that you
have a clean, unmodified git clone, we can't fix bugs caused by you failed to merge / rebase on
your own fork.

### Pull Requests

- **Create topic branches**. Don't ask us to pull from your master branch.

- **One pull request per feature**. If you want to do more than one thing, send
  multiple pull requests.

- **Send coherent history**. Make sure each individual commit in your pull
  request is meaningful. If you had to make multiple intermediate commits while
  developing, please squash them before sending them to us.

Please follow this process; it's the best way to get your work included in the project:

- [Fork](http://help.github.com/fork-a-repo/) the project, clone your fork,
   and configure the remotes:

```bash
   # clone your fork of the repo into the current directory in terminal
   git clone git@github.com:<your username>/LibreELEC.tv.git
   # navigate to the newly cloned directory
   cd LibreELEC.tv
   # assign the original repo to a remote called "upstream"
   git remote add upstream https://github.com/LibreELEC/LibreELEC.tv.git
   ```

- If you cloned a while ago, get the latest changes from upstream:

   ```bash
   # fetch upstream changes
   git fetch upstream
   # make sure you are on your 'master' branch
   git checkout master
   # merge upstream changes
   git merge upstream/master
   ```

- Create a new topic branch to contain your feature, change, or fix:

   ```bash
   git checkout -b <topic-branch-name>
   ```

- Commit your changes in logical chunks. or your pull request is unlikely
   be merged into the main project. Use git's
   [interactive rebase](https://docs.github.com/en/github/getting-started-with-github/about-git-rebase) feature to tidy up your commits before making them public.

- Push your topic branch up to your fork:

   ```bash
   git push origin <topic-branch-name>
   ```

- [Open a Pull Request](https://help.github.com/articles/using-pull-requests) with a
    clear title and description.

[Forum]: https://forum.libreelec.tv/
[issue]: https://github.com/LibreELEC/LibreELEC.tv/issues
[logfiles]: https://wiki.libreelec.tv/index.php?title=LibreELEC_FAQ#Support_Logs
[similar issue]: https://github.com/LibreELEC/LibreELEC.tv/search?&ref=cmdform&type=Issues
