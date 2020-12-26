quick notes:

* use aarch64 native homebrew, obviously. should be installed into `/opt/homebrew`
* use qemu from my branch, see qemu.rb.patch below to patch the homebrew formula. install with `brew install -vs --HEAD qemu`
* codesigning appears to be broken, so resign the binary with:
   ```sh
   xcrun codesign --entitlements ~/Source/qemu/accel/hvf/entitlements.plist --force -s - qemu-system-aarch64
   ```
   note: might run into codesign bug, so maybe sign a copy instead ... (thanks apple)
   ```sh
   cp qemu-system-aarch64 qemu-system-aarch64.tmp
   xcrun codesign --entitlements ~/Source/qemu/accel/hvf/entitlements.plist --force -s - qemu-system-aarch64
   rm -f qemu-system-aarch64
   cp qemu-system-aarch64.tmp qemu-system-aarch64
   rm -f qemu-system-aarch64.tmp
   ```
* run `./boot.sh`, which should download a debian installer and boot into it
* qemu doesnt seem to exit properly, so sometimes you'll need `pkill -9 qemu-system-aarch64`
* qemu enables userspace networking by default, so you'll have internet in the VM
* serial console is on stdout.
   EFI boot screen doesnt come up on serial - TBD; you can deduce from its debug output whats going on though
   monitor and serial0 is multiplexed, use `ctrl-a ?` to get help. notably `ctrl-a ctrl-a` produces one `ctrl-a`, useful for tmux in the installer
* `ssh -R 2244:127.0.0.1:22 somehome.example.org` is useful after installation


used versions:
* Homebrew 2.7.0-100-gda0d7ef
* xcode 12.2 full, xcode-select -p pointing to xcode, not clt
* macOS 11.1 20C69
* qemu 5.2.0 + master + hvf aarch64 patches, copy is at https://github.com/zeha/qemu/tree/plus-hvf-aarch64 rev e0ecc801be7993c8702ec096aad6bcfdee2b86fc
