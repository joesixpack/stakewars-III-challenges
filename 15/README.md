Kuutamod is an interesting "watcher" that takes care of automatic failover for NEAR nodes in case of any kind of failure.  It uses a pool of validators, with one validator being designated active and the other validators being designated passive which are always synced to the chain.  When a failover needs to occur, a passive validator will turn into an activate validator and be restarted with the correct keys.  Pretty cool.

LOCALNET

To test this out, I wanted to compile kuutamod to try out a NEAR localnet version in a cheap VPS.  The nix build and run of kuutamod didn't work on Ubuntu Jammy, so I had to clone the kuutamod repository, build a nix shell, then try to figure out how to get the nix-shell working to no avail.  So I built it without using nix, the good ol' tried and true way with rust and cargo.

After starting hivemind and two release versions of kuutamod, I was able to observe the logs, check the status via the Prometheus metrics endpoints and examine the localnet configuration dirs to get a better idea of how it is setup exactly.  It's prettying interesting that all kuutamod instances are symlinking to the keys instead of copying.  However, killing the first version of 
kuutamod didn't quite work as expected.  The second kuutamod wasn't synced and the blocks to download started to increase (get worse) for several minutes until it suddenly synced.  As they say, this is beta.

Anyway the next step was installing that gruesome NixOS.  Was simple enough to mount an ISO image and rebooted.  Unfortunately it was not a user-friendly installation process compared to Ubuntu.  Since this was a VPS, I was not able to manually partition and format the target drive, etc.  Several hours later, I finally got it to install properly and could login successfully.  Got it operational and was able to examine how it worked to successfully failover which was pretty interesting.

TESTNET

With the localnet in the bag, it was now time to try kuutamod out on NEAR testnet.  It took way too much time (several days) to find a suitable hosting provider as the testnet chain size is enormously large atm (337GB+) and needs Ryzen-level computing power to stay synced -- mulltiply that several times -- complicated by the fact that accursed NixOS has to be installed which is not an image available at most any host provider.  Even those that allow you to import a custom ISO image only support it for VPS/cloud, not dedicated servers.  Annoying.

