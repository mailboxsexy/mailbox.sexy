## Technical

* Each personal computer is its own email server sending and receiving personal
  emails from computer to computer.  There is no intermediaries!

* SMTP network works on available software, tested by years of use: Tor, Postfix,
  dovecot, Thunderbird...

* What we need is a secure transport, so we are going to make use of Tor. It
  provides secure transport, P2P addressing and authenticity of the recipient!
  The Tor network don't know that it's transmitting an email, neither who send
  or receive it, but the sender have the security that the email is received by
  the correct destination.

* The SMTP server only sends and receive email, and retry if the other end is not
  available. Because this we use onion addresses that only works inside Tor
  network.

* The whole system runs inside a [Systemd container](https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html), it has an small footprint on the host systemd, and maintains it isolated.
