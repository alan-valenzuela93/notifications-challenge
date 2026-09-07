# Notifications Challenge

Aplicación Flutter para gestionar notificaciones in-app.

## Requisitos

- Flutter SDK compatible con Dart `^3.12.2`.
- Para Android: Android SDK 37 y JDK 17.
- Para iOS: macOS con Xcode y CocoaPods configurados.
- El Bearer Token proporcionado para acceder a la API.

## Configuración del token

La aplicación recibe `API_BEARER_TOKEN` mediante `--dart-define-from-file`.
El archivo `secrets.example.json` incluido en el repositorio muestra la
estructura esperada y contiene únicamente un valor de ejemplo.

Crear manualmente un archivo llamado `secrets.json` en la raíz del proyecto
con el token proporcionado para el challenge:

```json
{
  "API_BEARER_TOKEN": "<TOKEN_PROVIDED_FOR_THE_CHALLENGE>"
}
```

`secrets.json` está excluido del repositorio.

## Ejecución del proyecto

```bash
flutter pub get
flutter run --dart-define-from-file=secrets.json
```
La aplicación falla al iniciar con un mensaje explícito si
`API_BEARER_TOKEN` no está configurado.

## Generar un APK

```bash
flutter build apk --dart-define-from-file=secrets.json
```

## Librerías principales utilizadas

La aplicación utiliza un conjunto reducido de paquetes, cada uno asociado a
una responsabilidad concreta de la solución:

| Dependencia | Uso y decisión técnica |
| --- | --- |
| `dio` | Cliente HTTP para consumir la API REST. Permite centralizar la URL base, el Bearer Token, los query parameters y los interceptores de diagnóstico en una sola instancia. |
| `bloc` | Provee `Cubit` para representar los estados del listado, la paginación y la creación de notificaciones sin colocar esa lógica dentro de los widgets. |
| `either_dart` | Modela de forma explícita el resultado de las operaciones como éxito o `ApiError`. Esto evita depender de excepciones de red dentro de presentation y obliga a contemplar ambos resultados. |
| `equatable` | Implementa igualdad por valor en estados, modelos y errores. Esto elimina comparaciones manuales y evita considerar diferentes dos estados que contienen los mismos datos. |
| `intl` | Formatea las fechas recibidas de la API y las seleccionadas por el usuario mediante `DateFormat`, conservando la conversión a la zona horaria local del dispositivo. |
| `logger` | Facilita el diagnóstico de requests y responses durante el desarrollo. El header de autorización se redacta para no exponer el Bearer Token. |

## Arquitectura utilizada

El proyecto utiliza una organización por funcionalidad con separación de
responsabilidades en capas. La feature de notificaciones contiene su UI y
manejo de estado, mientras que `core` reúne la integración con la API y los
componentes compartidos.

El flujo de las operaciones remotas es:

```text
Presentation / Cubit
        ↓
Use case
        ↓
Service
        ↓
DioClient
        ↓
REST API
```

- **Presentation** contiene páginas, widgets, validaciones y Cubits.
- **Cubit** representa estados de carga, éxito, vacío y error, además de la
  paginación y el envío del formulario.
- **Use cases** representan las operaciones de obtener y crear notificaciones.
- **Services** ejecutan las solicitudes y deserializan las respuestas.
- **DioClient** concentra la configuración HTTP y autenticación.

No se agregó una capa Repository porque la aplicación consume una única fuente
REST y la arquitectura actual no requiere coordinar múltiples orígenes de
datos.

## Decisiones técnicas

- Se utiliza `Cubit` para mantener el estado fuera de los widgets y conservar
  un flujo de datos predecible.
- Los services y use cases devuelven `Either<ApiError, T>` para representar de
  manera explícita éxito y error sin filtrar excepciones de Dio hacia la UI.
- Los modelos y estados implementan `Equatable` para compararse por valor.
- La serialización se implementa explícitamente porque el contrato es pequeño y
  no justifica incorporar generación de código para esta prueba. Las
  prioridades se representan mediante un enum y las fechas de la API se
  convierten a `DateTime` al deserializarlas.
- La paginación usa `limit`, `offset` y `meta.hasMore`. Cuando la lista tiene
  desplazamiento, la siguiente página se carga al acercarse al final. Si los
  resultados no alcanzan para generar scroll, se ofrece el botón `Cargar más`.
  Esta decisión depende del espacio ocupado por el contenido y no del tipo de
  dispositivo.
- Los filtros se envían como query parameters a la API; no se filtran resultados
  localmente.
- Los deep links se convierten en destinos tipados antes de navegar. Los
  destinos que están fuera del challenge se reconocen sin implementar pantallas
  inexistentes.
- El diseño utiliza `MediaQuery`, límites de ancho y componentes con scroll para
  adaptarse a diferentes tamaños, orientaciones y escalas de texto en Android e
  iOS.
- El Bearer Token se inyecta con `--dart-define-from-file` para evitar
  almacenarlo en el código fuente o versionarlo.

## Estructura de `core`

La carpeta `lib/core/` reúne código transversal que puede ser utilizado por
distintas funcionalidades de la aplicación.

```text
lib/core/
├── config/
├── extensions/
├── navigation/
├── notifications_api/
│   ├── endpoints/
│   ├── errors/
│   ├── models/
│   ├── services/
│   └── usecases/
└── presentation/
    ├── responsive/
    ├── state/
    └── widgets/
```

### `config/`

Contiene la configuración global obtenida en tiempo de compilación.
`AppConfig` lee `API_BEARER_TOKEN` mediante `String.fromEnvironment` y valida
que esté disponible antes de iniciar la aplicación. Esta capa no imprime ni
expone el valor del token.

### `extensions/`

Agrupa extensiones pequeñas y reutilizables. Actualmente incluye una extensión
para eliminar valores nulos de mapas antes de utilizarlos como parámetros o
payloads.

### `navigation/`

Implementa el procesamiento interno de deep links recibidos dentro de una
notificación:

- `NotificationLinkParser` valida la URI y la transforma en un destino tipado.
- Las clases `NotificationLinkDestination` representan los distintos destinos
  reconocidos por la aplicación.
- `NotificationLinkFailure` representa enlaces vacíos, inválidos o con un
  esquema no soportado.
- `NotificationLinkCoordinator` ejecuta la navegación disponible y delega a la
  pantalla el feedback de destinos inválidos o todavía no implementados.

Esta separación permite demostrar el manejo técnico de deep links sin agregar
pantallas ajenas al alcance del challenge.

### `notifications_api/`

Encapsula la integración con la API REST de notificaciones. El flujo de una
operación es:

```text
Presentation / Cubit
        ↓
Use case
        ↓
NotificationsService
        ↓
DioClient
        ↓
REST API
```

Sus componentes tienen las siguientes responsabilidades:

- `api_constants.dart` define la URL base del backend.
- `dio_client.dart` mantiene una única instancia de Dio, configura headers,
  incorpora el Bearer Token y registra información de diagnóstico durante el
  desarrollo.
- `endpoints/` concentra las rutas utilizadas por el service.
- `models/` contiene los DTOs de creación, filtros, notificaciones y metadata
  de paginación. Los modelos implementan igualdad por valor mediante
  `Equatable`.
- `errors/` contiene `ApiError` y los tipos de error de red, autenticación,
  timeout y respuestas con formato inválido.
- `services/` realiza los requests, deserializa las respuestas y transforma los
  errores técnicos en `Either<ApiError, T>`.
- `usecases/` expone las operaciones de obtener y crear notificaciones sin
  filtrar detalles de Dio hacia presentation.
- `_notifications_api.dart`, `_models.dart` y `_use_cases.dart` funcionan como
  archivos de exportación para simplificar imports.

### `presentation/`

Contiene elementos visuales y estados genéricos reutilizados por las pantallas
mobile:

- `responsive/` adapta espaciados, tamaños, paddings y ancho máximo según las
  dimensiones reportadas por `MediaQuery`.
- `state/` define estados visuales comunes como carga, éxito, vacío y error. Esto está inspirado en GetX, pero no se incluyó ese paquete ya que     sería excesivo para esta solución.
- `widgets/` contiene componentes compartidos para textos, formularios,
  indicadores de carga y vistas de error o contenido vacío.
