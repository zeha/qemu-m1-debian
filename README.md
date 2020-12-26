quick notes:

*) use aarch64 native homebrew, obviously
*) use qemu from my branch, see qemu.rb.patch below to patch the homebrew formula. install with `brew install -vs --HEAD qemu`
*) codesigning appears to be broken, so resign the binary with 
   `xcrun codesign --entitlements ~/Source/qemu/accel/hvf/entitlements.plist --force -s - qemu-system-aarch64`
   note: might run into codesign bug, so maybe `cp` qemu-system-aarch64 first and sign the copy, then swap the files
*) run `./boot.sh`, which should download a debian installer and boot into it
*) qemu doesnt seem to exit properly, so sometimes you'll need `pkill -9 qemu-system-aarch64`
*) qemu enables userspace networking by default, so you'll have internet in the VM
*) serial console is on stdout.
   EFI boot screen doesnt come up on serial - TBD; you can deduce from its debug output whats going on though
   monitor and serial0 is multiplexed, use `ctrl-a ?` to get help. notably `ctrl-a ctrl-a` produces one `ctrl-a`, useful for tmux in the installer
*) `ssh -R 2244:127.0.0.1:22 somehome.example.org` is useful after installation
   