## Why not use ×?

There're lots of project that try to reinvent e-mail's wheel, or replace
with something else.  The issue is that they start with the user
interfaces, thus discarding years of work without solving the real
issue, the centralization of communication between people.  We don't
want to reinvent the wheel, we want something that works today.

## Hidden services are difficult to read and remember!

Until someone figures out Zooko's triangle, this is what we have.  It
could be worse, such as identities on
[Pond](https://github.com/agl/pond), [Tox](https://tox.chat/), etc.  You
can always use your addressbook to remember your friends identities.

## Why on a container!

We could've distributed mailbox.sexy in a way where you'd run it on your
prefered operating system, but we prefered to save ourselves some
headaches by making the minimal amount of changes to the host, very
probably incompatible between systems, so we standarized everything in a
single operating system, running inside a container.  We chose
`systemd-nspawn` because is a container management tool already
available on most GNU/Linux distributions.

## Why `systemd-nspawn`?  Systemd is shit!

You're welcome to send patches to make mailbox.sexy work on any other
container management tool :3

## How can I have several users on the same hiddenservice.onion?

We're still working on this, patches welcome!
