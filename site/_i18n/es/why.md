#### ¿Por qué no ×?

Existen muchos proyectos que intentan reinventar el correo electrónico, o
reemplazarlo por otra cosa.  El problema es que empiezan por las interfaces de
usuaria, descartando años y años de trabajo, sin solucionar el problema real,
que es la centralización de las comunicaciones entre personas.  Nosotras no
queremos reinventar la rueda, queremos algo que funcione hoy.

#### ¡Los hiddenservice.onion son difíciles de leer y recordar!

Hasta que alguien resuelva el triángulo de Zooko, es lo mejor que tenemos.
Podría ser peor, como las identidades en [Pond](https://github.com/agl/pond),
[Tox](https://tox.chat/), etc.
Siempre podés usar la libreta de direcciones para recordar las identidades de
tus amigas.

#### ¡Por qué en un container!

Podríamos haber distribuido mailbox.sexy de forma que pueda correr en tu
sistema operativo preferido, pero preferimos ahorrarnos dolores de cabeza
haciendo los menores cambios en el host, muy probablemente incompatibles con
las diferentes instalaciones, por lo que estandarizamos todo en un solo sistema
operativo, corriendo en un contenedor.  Elegimos `systemd-nspawn` porque es una
herramienta de gestión de contenedores disponible en la mayoría de las
distribuciones más usadas.

#### ¿Por qué `systemd-nspawn`? ¡Systemd es una mierda!

Estás invitada a mandarnos parches para hacer que mailbox.sexy funcione en
cualquier otro gestor de contenedores :3

#### ¿Cómo puedo tener varias usuarias dentro del mismo hiddenservice.onion?

Todavía no estamos trabajando en esto, ¡mandanos parches!


