# mailbox.sexy

> Make e-mail sexy again!

## Descripción

Mailbox.sexy es e-mail entre pares.  Es como un buzón dentro del sistema
de correo, donde este llega directamente a tu casa, de forma anónima y
sin intermediarios!

Así es como debería ser el _email_.  Lo envías desde tu `~` y las demás
lo reciben en el suyo.  No hay máquinas de terceros ni humanos
interfiriendo en tus comunicaciones.

## Cómo funciona

Mailbox.sexy aprovecha los _servicios ocultos_ de la red
[Tor](https://torproject.org) para crear direcciones de correo únicas
con el formato `mailbox@sarasa.onion`.  Al enviar un correo a esta
dirección, mailbox.sexy despacha tu correo a través de Tor.

Los nodos intermedios no sabrán su contenido, tampoco a quién se lo
enviaste.  ¡Ni siquiera saben que estuviste enviando correo!

[Leer más](spec.html)

## Instalación

```bash
# Trabajar como root
sudo bash
# Descargar
wget https://github.com/mailboxsexy/mailbox.sexy/releases/download/2017-03-25/mailbox.local.2017-03-25.x86_64.tar.xz
# Extraer
tar xvf mailbox.local.2017-03-25.x86_64.tar.xz
# Instalar
cd mailbox.local.2017-03-25.x86_64
make all
# Hacer limpieza
cd ..
rm -r mailbox.local.2017-03-25.x86_64*
```

Este proceso instala el contenedor de _mailbox.sexy_ en
`/var/lib/machines`.  A partir de esto momento, se lo puede manipular
con `machinectl(1)` o `mailbox.sexy`.

## Configuración

Si usas [Thunderbird](https://www.mozilla.org/es-ES/thunderbird/),
agrega una nueva cuenta llamada `mailbox@mailbox.local`.  Esta siempre
va a ser la dirección local y se convierte a
`mailbox@hiddenservice.onion` al enviar correo.  Thunderbird
autoconfigurará la cuenta.

Si estás usando otro cliente que no soporta autoconfiguración, los datos
son:

* Usuaria: mailbox
* Contraseña: la que indicaste durante la instalación
* SMTP: mailbox.local:587 (STARTTLS)
* IMAP: mailbox.local:993 (TLS)
* POP3: mailbox.local:995 (TLS)

