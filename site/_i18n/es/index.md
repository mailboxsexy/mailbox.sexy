# mailbox.sexy

> Make e-mail sexy again!

## Descripción

Mailbox.sexy ese-mail entre pares.  Es como un buzón dentro del sistema de correo,donde el correo llega directamente a tu casa, de forma anónima y sin intermediarios!

Esto es como deberíaser el _email_, _P2P_.  lo envías desde tu ~ y las
demás lo reciben en el suyo.  No hay máquinas de terceros ni humanos
interfiriendo en tus comunicaciones.

## Cómo funciona

Mailbox.sexy aprovecha los _servicios ocultos_ de la red [Tor](https://torproject.org) para crear direcciones de correo únicas con el formato `mailbox@sarasa.onion`.  Al enviar un correo a esta dirección, el servidor envía tu correo a través de Tor.  Los nodos intermedios no saben el contenido del correo, o a quién se lo enviaste.  ¡Ni siquiera saben que estuviste enviando correo!

[Leer más](spec.html)

## Instalación

Crear el contenedor desde cero:

```bash
make email sexy again
```

O descargarlo:

```bash
tar xvf mailbox.tar.xz
cd mailbox
sudo make install
sudo systemctl restart systemd-nspawn@mailbox.service
```

