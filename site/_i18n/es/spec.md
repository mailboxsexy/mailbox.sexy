
## Técnica

* Cada computadora personal es su propio servidor de correo enviando y recibiendo correos personales _¡sin intermediarios!_ de computadora a computadora.  No hay intermediarios!

* La red SMTP funciona con software ya disponible y probado hace años: Tor, Postfix, Dovecot, Thunderbird...

* Lo que necesitamos es un transporte seguro, por lo que vamos a usar para esto usamos Tor. Ya que provee tanto el transporte seguro y P2P como el direccionamiento y la autenticación del destino!  La red Tor no sabe que está transmitiendo un correo, ni quien lo envía ni quien lo recibe, pero la emisora tiene la seguridad que el correo es recibido por el destinatario correcto.

* El servidor SMTP solo se encarga de enviar y recibir correo y de reintentar si el otro lado no está disponible.  Para esto usamos direcciones mailbox@mailboxsexy.onion que solo funcionan dentro de la red Tor.

* El sistema corre dentro de un [contenedor de Systemd](https://www.freedesktop.org/software/systemd/man/systemd-nspawn.html), deja una huella mínima de modificaciones en el sistema anfitrión, y lo mantiene aislado del mismo.
