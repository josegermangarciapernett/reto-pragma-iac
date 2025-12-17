# Observaciones del marco de trabajo

## Credenciales del Cloud Provider

### AWS

Para el proveedor de AWS es posible seleccionar dos alternativas:

- Usar profiles: se cuenta con variable y parametro contienen el nombre del perfil local de AWS CLI del ambiente en el cual se quiere realizar el despliegue de la infraestructura y el profile usado para conectarse a los recursos del backend de Terraform.
- Suministrar las variables de usuario IAM: estas vaibales tienen por defecto un valor nulo, para hacer uso de ellas se deben creal las siguiente variables de entorno:
    ```sh
    # Variables con credenciales de la cuenta de despliegue
    export TF_VAR_aws_access_key="AKIAUMSDEFT6A9LTTOFP"
    export TF_VAR_aws_secret_key="rixzlxnHnrh+KpXuDLkQyx6PiXzBR51ZaBark35q"
    # Variables con credenciales para conectarse al backend de Terraform
    export AWS_ACCESS_KEY_ID="AKIARGKJBC24B95B4OKE"
    export AWS_SECRET_ACCESS_KEY="g1QYSIVtALLJQt2NGiN8FIFQn7LiBfp5grpgGeqe"
    ```
> **Nota:** Si se exportan las variables de entorno el profile definido por la variable profile en función del workspace de Terraform no será usado.

## Uso de Terragrunt

Este proyecto contiene el desarrollo de codigo de IaC usando como lenguaje base Terraform, para la definición del marco de trabajo se opto por emplear el wrapper de Terragrunt el cual nos permite dar manejo a las siguientes situaciones.

- Minimizar el DRY (Don't repeat yourself), generando de forma automática los ficheros de remotebackend.tf y provider.tf para los recursos y capas del proyecto.
- Manejo de dependencias entre recursos de con diferentes fichero de estado, contenidos dentro de un directorio padre.

## Estructura del proyecto

```sh
├── CHANGELOG.md
├── README.md
├── common
│   ├── common.hcl
│   ├── common.tfvars
│   └── variables.tf
├── docs
├── modules
├── resources
│   ├── compute
│   │   ├── README.md
│   │   ├── data.tf
│   │   ├── graph.svg
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── parameters.tf
│   │   ├── provider.tf
│   │   ├── remotebackend.tf
│   │   ├── terragrunt.hcl
│   │   └── variables.tf
│   ├── network
│   │   ├── README.md
│   │   ├── data.tf
│   │   ├── graph.svg
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── parameters.tf
│   │   ├── provider.tf
│   │   ├── remotebackend.tf
│   │   ├── terragrunt.hcl
│   │   └── variables.tf
│   └── ...
├── terragrunt.hcl
└── test
    └── tests.json
```

## Comando para manipulacion del proyecto:

### Comandos generales

```sh
# Inicializar proyecto (descargar provider, modules, etc)
$ terragrunt init
# Visualizar acciones que se realizaran
$ terragrunt plan
$ terragrunt plan -out=tfplan
# Aplicar acciones sobre los recursos
$ terragrunt apply
# Eliminar los recursos desplegados
$ terragrunt destroy
```

### Comando para manipulación de workspaces

```sh
# Listar los workspaces creados
$ terragrunt workspace list
# Creación de un workspace
$ terragrunt workspace new dev
# Eliminación de un workspace
$ terragrunt workspace delete dev
# Seleccionar el workspace de trabajo
$ terragrunt workspace select dev
```

### Alcance de acciones

1. Aplicar acción a directorio en especifico:

    ```sh
    # En directorio del recurso o capa (path_project/resources/network)
    $ terragrunt init
    ```

2. Aplicar acción a todo el proyecto:

    ```sh
    # Desde directorio raiz del proyecto (path_project)
    $ terragrunt run-all init --terragrunt-exclude-dir .
    ```

    ```sh
    # Desde directorio padre sin terragrunt.hcl (path_project/resources)
    $ terragrunt run-all init
    ```

## Generar diagrama de dependencias

```bash
terragrunt graph-dependencies | dot -Tsvg > ./docs/img/graph.svg
```

### Ejecución de comando para todo el proyecto

```sh
# Generar documentación en formato mas popular: 'markdown table'
terraform-docs markdown table --output-file README.md .
# Generar documentación usando archivo de documentación
terraform-docs -c .terraform-docs.yml .
```
