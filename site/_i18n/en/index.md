# mailbox.sexy

## Description

Mailbox.sexy is P2P e-mail.  It's like a mailbox on the snail mail
systemd, where mail gets delivered directly to your home, anonymously
and without intermediaries!

This is how e-mail should be.  You send it from your `~` and people
receives it on theirs.  No third party machines nor humans meddling in
your communications.

## How does it work

Mailbox.sexy runs on [Tor](https://torproject.org)'s _hidden services_,
using addresses in the format `mailbox@anything.onion`.  When you send
e-mail to such addresses, mailbox.sexy delivers them over Tor.

Intermediate Tor nodes won't know its contents, nor its recipients.
They don't even know you were sending e-mail!

[Read more](spec.html)

## Install

```bash
# Work as root
sudo bash
# Download
wget https://github.com/mailboxsexy/mailbox.sexy/releases/download/2017-03-25/mailbox.local.2017-03-25.x86_64.tar.xz
# Extract
tar xvf mailbox.local.2017-03-25.x86_64.tar.xz
# Install
cd mailbox.local.2017-03-25.x86_64
make all
# Clean up
cd ..
rm -r mailbox.local.2017-03-25.x86_64*
```

This process installs mailbox.sexy's container on `/var/lib/machines`.
From this moment on, you can manipulate it with `machinectl(1)` or
`mailbox.sexy`.

## Configuration

If you use [Thunderbird](https://www.mozilla.org/en-US/thunderbird/),
add a new account called `mailbox@mailbox.local`.  This will be your
local address, and gets converted to `mailbox@hiddenservice.onion` when
you send e-mail.  Thunderbird will auto-configure this account.

If you're using another client that doesn't support auto-configuration,
the information you need is this:

* User: mailbox
* Password: the one you selected
* SMTP: mailbox.local:587 (STARTTLS)
* IMAP: mailbox.local:993 (TLS)
* POP3: mailbox.local:995 (TLS)

