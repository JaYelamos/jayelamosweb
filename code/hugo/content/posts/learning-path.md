---
title: "Mi Ruta de aprendizaje"
date: 2024-12-20T13:23:08+01:00
draft: false
toc: false
images:
tags:
  - aws
  - opentofu
  - hugo
  - iac
---
![alt text](/posts/images/webInfrastructure.png)

## La Inspiración y el Proyecto

En los últimos días, he estado dándole vueltas a la idea de crear algunos proyectos para aprender nuevas tecnologías, mantenerme ocupado y compartir conocimientos sobre el fascinante mundo del SRE (aunque, para ser sincero, no es tan maravilloso como parece 😅).

El problema es que, al intentar crear un proyecto desde cero sin un plan claro, me sentía bloqueado. Sin embargo, la inspiración llegó (o más bien, la copié de un colega, para ser honesto).

Revisando mi LinkedIn, encontré un post de mi compañero Darren Fuller. En su blog personal, compartía algunas experiencias y lecciones sobre nuestro trabajo. Esto me dio la idea: ¡crear un blog parecido! Un lugar donde pudiera compartir mis problemas, soluciones y pensamientos sobre este mundo de la infraestructura y el SRE.

Así que, decidí ponerme manos a la obra. Revisé la herramienta que él estaba usando, y descubrí que empleaba el framework **Hugo**.

## Elegir Hugo para mi Proyecto

Tras investigar un poco sobre **Hugo**, me di cuenta de que era perfecto para lo que quería hacer. Es un framework ligero, fácil de configurar y rápido, lo que lo hace ideal para un sitio estático como el que tenía en mente.

Algunos podrían preguntarse: ¿por qué no usar algo como **WordPress**? Bueno, la razón principal es que **WordPress** es muy pesado para este tipo de proyecto. Aunque WordPress tiene muchas ventajas y facilidades, mi objetivo era mantener las cosas simples y rápidas. Además, integrarlo con otros servicios como AWS hubiera sido más complicado. Si hubiera usado WordPress, necesitaría configurar una instancia EC2, una base de datos, o incluso un contenedor de WordPress en AWS, lo que complicaba mucho las cosas.

En cambio, Hugo es rápido y sencillo, lo que se ajusta perfectamente a mis necesidades. Mientras que WordPress se enfoca en ser personalizable y ofrecer muchas funcionalidades (como e-commerce), Hugo es ideal para sitios estáticos rápidos.

## Integrando OpenTofu para IaC

La segunda parte de este proyecto fue usar **OpenTofu**. Ya tengo experiencia con **Biceps** y quería explorar una alternativa para gestionar infraestructura como código (IaC). Algunos podrían preguntar: ¿por qué no usar **Terraform**? La razón principal es el cambio de licencia de Terraform y el hecho de que **OpenTofu** es Open Source, lo que me resulta más atractivo.

## El Despliegue en AWS

La última pieza clave de este proyecto es **AWS**. Tengo experiencia trabajando con **Azure**, pero mis conocimientos en AWS son más básicos. Así que, para este proyecto, todo estará desplegado en la nube de AWS.

---

## Uniendo las Piezas

### Creando los Recursos con OpenTofu

Primero, me puse a trazar un plan. Necesitaba desplegar la infraestructura con **OpenTofu** en **AWS**. Así que, me pregunté: ¿qué servicios de AWS utilizaré?

Dado que quiero desplegar un sitio estático, hay varias opciones disponibles en AWS. Las que consideré fueron:

- **S3 Bucket**: AWS ofrece la opción de alojar un sitio estático en un bucket de S3.
- **Amplify**: un servicio que simplifica el alojamiento de sitios web estáticos.
- **Lambda**: la opción de Function-as-a-Service de AWS.

Decidí usar **Amplify** por varias razones. No estaba seguro de si S3 Bucket ofrecía una forma sencilla de actualizar la web automáticamente cuando hiciera cambios. Es posible hacerlo con Lambda o GitHub Actions, pero no era lo que buscaba. Además, Lambda lo veo más adecuado para backend o APIs, así que lo descarté.

**Amplify** me pareció la opción más adecuada, por lo que me puse manos a la obra. Configuré **Amplify** en **OpenTofu**, y aunque había algunas diferencias con Biceps, logré crear un módulo en mi código de **Terraform** para desplegar todo lo necesario para el sitio web (en ese momento solo era Amplify y la configuración del repositorio en GitHub).

### El Problema de Conectar Amplify con GitHub

Sin embargo, cuando intenté desplegar el recurso, me encontré con un error. "¡DIABLO!", exclamé. ¿Qué podría estar fallando?

Tras investigar un poco, me di cuenta de algo importante: Amplify no puede conectarse mágicamente con mi repositorio público en GitHub. Así que, tuve que crear un **PAT token** (Personal Access Token) para permitir la conexión.

Creé el token, lo configuré en mi archivo `.tfvars`, pero aún seguía fallando. El problema era que no le había dado los permisos adecuados. Estuve revisando la documentación de **Amplify** y **GitHub**, pero no encontraba detalles claros sobre qué permisos necesitaba. Tras probar diferentes combinaciones, logré configurarlo correctamente con los permisos mínimos.

Finalmente, el recurso de **Amplify** pudo conectarse a GitHub y obtener el código. ¡Éxito!

### Configurando el Build en Amplify

Ahora que **Amplify** podía acceder al código, el siguiente paso era configurar el proceso de **build**. Amplify ofrece un flujo de trabajo sencillo para compilar y desplegar sitios estáticos, así que me puse a configurar los ajustes para que todo funcionara perfectamente.

Creé la configuración para el build y creación del artefacto que usará Amplify. Quedaría de la siguiente forma:

```yaml
  resource "aws_amplify_app" "amplifyapp" {
  name       = "jayelamosweb"
  repository = var.repositoryUrl
  access_token = var.accesstoken

  # The default build_spec added by the Amplify Console for React.
  build_spec = <<-EOT
    version: 1
    env:
      variables:
        # Application versions
        DART_SASS_VERSION: 1.81.0
        GO_VERSION: 1.23.3
        HUGO_VERSION: 0.139.3
        # Time zone
        TZ: Europe/Madrid
        # Cache
        HUGO_CACHEDIR: $${PWD}/.hugo
        NPM_CONFIG_CACHE: $${PWD}/.npm
    frontend:
      phases:
        preBuild:
          commands:
            # Install Dart Sass
            - curl -LJO https://github.com/sass/dart-sass/releases/download/$${DART_SASS_VERSION}/dart-sass-$${DART_SASS_VERSION}-linux-x64.tar.gz
            - sudo tar -C /usr/local/bin -xf dart-sass-$${DART_SASS_VERSION}-linux-x64.tar.gz
            - rm dart-sass-$${DART_SASS_VERSION}-linux-x64.tar.gz
            - export PATH=/usr/local/bin/dart-sass:$PATH

            # Install Go
            - curl -LJO https://go.dev/dl/go$${GO_VERSION}.linux-amd64.tar.gz
            - sudo tar -C /usr/local -xf go$${GO_VERSION}.linux-amd64.tar.gz
            - rm go$${GO_VERSION}.linux-amd64.tar.gz
            - export PATH=/usr/local/go/bin:$PATH

            # Install Hugo
            - curl -LJO https://github.com/gohugoio/hugo/releases/download/v$${HUGO_VERSION}/hugo_extended_$${HUGO_VERSION}_linux-amd64.tar.gz
            - sudo tar -C /usr/local/bin -xf hugo_extended_$${HUGO_VERSION}_linux-amd64.tar.gz
            - rm hugo_extended_$${HUGO_VERSION}_linux-amd64.tar.gz
            - export PATH=/usr/local/bin:$PATH

            # Check installed versions
            - go version
            - hugo version
            - node -v
            - npm -v
            - sass --embedded --version

            # Install Node.JS dependencies
            - "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci --prefer-offline || true"

            # https://github.com/gohugoio/hugo/issues/9810
            - git config --add core.quotepath false
        build:
          commands:
            - cd code/hugo/
            - hugo --gc --minify
      artifacts:
        baseDirectory: code/hugo/public
        files:
          - '**/*'
      cache:
        paths:
          - $${HUGO_CACHEDIR}/**/*
          - $${NPM_CONFIG_CACHE}/**/*
  EOT
```

Básicamente, **build_spec** indica los pasos a seguir para construir el código. En nuestro caso, es sencillo (aunque largo).  
Descargamos primero **Dart Sass, Go y Hugo**, e instalamos depencias de npm que son los paquetes necesarios para la construcción del código estático.

Una vez que tenemos todo listo, accederemos a la ruta donde tenemos nuestra instalación de **Hugo** en el repositorio y ejecutaremos el siguiente comando:
```bash
  hugo --gc --minify
```

Este comando genera los archivos estáticos para nuestro sitio web.

Finalmente, le indicamos a **Amplify** que los archivos a utilizar se encuentran en la carpeta **/public**, que se crea automáticamente después de ejecutar el comando anterior. **Amplify** tomará estos archivos estáticos, los guardará en el **artefacto** y los subirá a su plataforma para el despliegue.

### Añadiendo un Dominio Personalizado

Para finalizar, decidí agregar un **dominio personalizado** a mi sitio para darle un toque más profesional y facilitar el acceso al blog. **Amplify** ofrece una integración sencilla para conectar un dominio, y en este caso, la configuración fue bastante fácil.  

Opté por obtener el dominio a través de **AWS**, ya que la configuración de los registros necesarios para enlazar **Amplify** con el dominio se realiza automáticamente. El dominio que elegí fue **jayelamos.com**.  

Una vez registrado el dominio, modifiqué el módulo de **OpenTofu** para incluir la sección de `customDomains` en el recurso de **Amplify**, quedando de la siguiente manera:


```yaml
resource "aws_amplify_domain_association" "customDomain" {
  app_id      = aws_amplify_app.amplifyapp.id
  domain_name = "jayelamos.com"
  wait_for_verification = false

  # https://jayelamos.com
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }

  # https://www.jayelamos.com
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "www"
  }
```

Añadí tanto el dominio con **www** como sin él, para asegurar que los usuarios puedan acceder al sitio de ambas formas. Al registrar el dominio con **AWS** y agregar estos bloques en **OpenTofu**, al desplegar automáticamente se generaron los certificados **SSL** necesarios y los registros **DNS** en la zona correspondiente.

Si el dominio fuera externo, se requerirían pasos adicionales para configurar los registros **DNS** manualmente.

Finalmente, modifiqué la configuración de **Hugo** para establecer **jayelamos.com** como la URL principal del sitio. Esto asegura que, incluso si eliminamos y creamos un nuevo recurso, la URL permanecerá constante, evitando posibles errores relacionados con cambios de URL.

---

## Conclusiones

Este proyecto me permitió aprender y aplicar varias herramientas nuevas: **Hugo** para la creación del sitio, **OpenTofu** para la gestión de infraestructura como código, y **AWS Amplify** para desplegar el sitio estático. Aunque encontré algunos obstáculos, como los problemas con los permisos de GitHub, al final pude superar los desafíos y construir una solución funcional.

Este proyecto no solo me ayudó a aprender, sino que también me permitió ver cómo diferentes tecnologías pueden trabajar juntas para lograr algo sencillo, rápido y eficaz. ¡Definitivamente un buen punto de partida para seguir aprendiendo!



---

¡Espero que te haya resultado útil este recorrido por mi proceso! ¿Tienes alguna duda o sugerencia? ¡Déjamela en cualquier de mi perfil de RRSS o email!  
Recuerda que si quieres revisar en profundidad el proyecto y los ficheros, puedes acceder al repositorio del proyecto [aquí](https://github.com/JaYelamos/jayelamosweb)
