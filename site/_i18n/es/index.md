# mailbox.sexy

> Make e-mail sexy again!

## Descripción

Mailbox.sexy es e-mail entre pares.  Es como un buzón dentro del sistema de
correo, donde el Este llega directamente a tu casa, de forma anónima y sin
intermediarios!

Así es como debería ser el _email_, _P2P_.  Lo envías desde tu **~** y las
demás lo reciben en el suyo.  No hay máquinas de terceros ni humanos
interfiriendo en tus comunicaciones.

## Como funciona

Mailbox.sexy aprovecha los _servicios ocultos_ de la red
[Tor](https://torproject.org) para crear direcciones de correo únicas con el
formato `mailbox@sarasa.onion`.  Al enviar un correo a esta dirección, mbs
despacha tu correo a través de Tor.  Los nodos intermedios no sabrán su
contenido, tampoco a quien se lo enviaste.
¡Ni siquiera saben que estuviste enviando correo!

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

## Configuración

Si usas [Thunderbird](https://www.mozilla.org/es-ES/thunderbird/), agrega una
nueva cuenta llamada `mailbox@mailbox.local`.  Esta siempre va a ser la
dirección local y se convierte a mailbox@hiddenservice.onion al ser enviada.
Thunderbird autoconfigurará la cuenta.

Si estás usando otro cliente que no soporta autoconfiguración, los datos son:

* Usuaria: mailbox
* Contraseña: la que indicaste durante la instalación
* SMTP: mailbox.local:587 (STARTTLS)
* IMAP: mailbox.local:993 (TLS)
* POP3: mailbox.local:995 (TLS)

