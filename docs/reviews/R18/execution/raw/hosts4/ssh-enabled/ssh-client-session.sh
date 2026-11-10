#!/bin/bash
mode=$(stty -g)
printf "%s\n" "$mode" > /workspace/work/session-extension-execution/raw/hosts4/ssh-enabled/client-termios-before
trap 'stty "$mode"; stty -g > /workspace/work/session-extension-execution/raw/hosts4/ssh-enabled/client-termios-after' EXIT
stty raw -echo
/usr/bin/ssh -vvv -E /workspace/work/session-extension-execution/raw/hosts4/ssh-enabled/ssh-client.log -F /dev/null -p 22473 -i /workspace/work/session-extension-recon/ssh/private/client_ed25519 -o IdentitiesOnly=yes -o BatchMode=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=/workspace/work/session-extension-recon/ssh/private/known_hosts -o GlobalKnownHostsFile=/dev/null -o ForwardAgent=no -o ForwardX11=no -o ClearAllForwardings=yes -o ControlMaster=no -o ProxyCommand=none -T agent@127.0.0.1 '/usr/bin/script --quiet --flush --return --log-out /workspace/work/session-extension-execution/raw/hosts4/ssh-enabled/remote-pty-ansi.bin --command '"'"'/bin/bash -c '"'"'"'"'"'"'"'"'source /workspace/work/validation/sdk/cangjie/envsetup.sh; stty rows 28 cols 100; exec /workspace/work/session-extension-execution/source/tests/session_extensions/host-consumer.sh /workspace/work/session-extension-execution/source/tests/session_extensions/target/release/bin/main /workspace/work/session-extension-execution/raw/hosts4/ssh-enabled/consumer Direct declared'"'"'"'"'"'"'"'"''"'"''
exit $?
