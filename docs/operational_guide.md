# Guía de operaciones

## Acciones generales

- Se debe realizar verificación periódica de actualizaciones en recursos y módulos usados en el proyecto, esto con el objetivo de mantener un codigo que mantiene estándares de seguridad y calidad. Al realizar actualizaciones de codigo se recomienda seguir los siguientes pasos:

    1. Actualizar versión de herramienta, provider o módulo de forma periódica.
    2. Realizar plan sobre ambiente de pruebas y verificar las acciones que se realizaran.
    3. Definir y analizar el impacto que las acciones que se realizarán tendrán sobre el despliegue de la solución.
    4. A Se pueden presentar situaciones en las cuales se requiriera adicionar o remover atributos y la falta de aplicar estas acciones generen errores de ejecución.
    5. Aplicar cambios y realizar pruebas sobre ambiente de desarrollo.
    6. Verificar que los cambios aplicados permitan que la solución siga funcionando de la manera deseada.
    7. Aplicar cambios a los demás ambientes y realizar pruebas de regresión.

- Realizar escaneos de codigo de forma  frecuente y evaluar si las acciones de mejora son aplicables, en funcione de las modificaciones que se deben realizar a cada ambiente en especifico.

## Acciones por capa

### Capa de computo

- Actualización de atributos de instancias:
    1. AMI: al momento de lanzar una instancia se define la AMI con la que será despegada la instancia, siendo un atributo que de ser actualizado generar la destrucción de la instancia, su proceso de actualización debe ser analizado a detalle.

### Capa de base de datos

- Actualización de atributos de base de datos:
    1. Credenciales de administrador: al momento de lanzar la instancia se definió que utilizara credenciales master y al aplicar esta configuración el servicio de RDS se encarga de actualizar de forma automática las credenciales de administrador de la base de datos, además de crear y actualizar secreto de Secrets Manager que contiene estas credenciales. Por lo que antes de establecer conexión a la base de datos se recomienda verificar que las credenciales que serán utilizadas sean las definidas en el secreto.