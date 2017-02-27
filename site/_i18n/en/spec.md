## Técnica

* Cada computadora personal es su propio servidor de correo enviando y recibiendo correos personales de computadora a computadora.  No hay intermediarios!

* La red SMTP funciona con software ya disponible y probado hace años: Tor, Postfix, Dovecot, Thunderbird...

* Lo que necesitamos es un transporte seguro, por lo que vamos a usar Tor, pero podría intercambiarse por cualquier transporte confiable: una VPN (como LibreVPN o cjdns) por ejemplo.  Los transportes inseguros son: Internet, redes locales, redes libres (!)[^redeslibres]...

[^redeslibres]: Las redes libres no se caracterizan por preocuparse por la seguridad del transporte.  (Incluso algunos de sus proponentes se divierten inspeccionando el tráfico que pasa por sus nodos...)

  Tor provee tanto el transporte seguro y P2P como el direccionamiento y la autenticación del destino!  La red Tor no sabe que está transmitiendo correo, ni quien lo envía ni quien lo recibe, pero quien envía tiene la seguridad que el correo es recibido por el destinatario correcto.

  * El servidor SMTP solo se encarga de enviar y recibir correo y de reintentar si el otro lado no está disponible.  Para esto usamos direcciones mailbox@mailboxsexy.onion que solo funcionan dentro de la red Tor.
