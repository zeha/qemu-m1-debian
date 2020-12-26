quick notes:

* use aarch64 native homebrew, obviously. should be installed into `/opt/homebrew`
* use qemu from my branch, see `qemu.rb.patch` to patch the homebrew formula. then install with `brew install -vs --HEAD qemu`
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
* run `./boot.sh`, which should download a debian installer and boot into it. just restart `boot.sh` again to boot from harddisk image after install
* qemu doesnt seem to reboot or exit properly, so sometimes you'll need `pkill -9 qemu-system-aarch64`
* qemu enables userspace networking by default, so you'll have internet in the VM
* console:
   - serial console (serial0) is on stdout.
   - EFI boot screen is in a Cocoa window. EFI debug goes to serial (stdout).
   - serial0 and qemu monitor are multiplexed. use `ctrl-a ?` to get help. notably `ctrl-a ctrl-a` produces one `ctrl-a`, useful for tmux in the installer.

   **Setup Linux console:** \
   At the installer's grub prompt (blue menu) - in the Cocoa window:
   * edit `Install` option:
   * press `e` to edit the option
   * replace `quiet` with `console=tty1,ttyAMA0` (cursor keys and `ctrl-e` work in this editor -- see `screenshot-grub-console.png`)
   * `ctrl-x` boots the installer. Should have console on Cocoa output.
   * Debian installer is smart enough (!) to copy `console=...` into the final installation.
* `ssh -R 2244:127.0.0.1:22 somehome.example.org` is useful after installation


used versions:
* Homebrew 2.7.0-100-gda0d7ef; homebrew-core bcd3c911ecdd41b8788e68481db3a9e5b7d24c45
* xcode 12.2 full, xcode-select -p pointing to xcode, not clt
* macOS 11.1 20C69
* qemu 5.2.0 + master + hvf aarch64 patches, copy is at https://github.com/zeha/qemu/tree/plus-hvf-aarch64 rev e0ecc801be7993c8702ec096aad6bcfdee2b86fc


links:
* https://qemu.readthedocs.io/en/latest/system/index.html
* https://patchwork.kernel.org/project/qemu-devel/list/?series=391797
* https://github.com/Homebrew/brew/issues/9082#issuecomment-727247739
