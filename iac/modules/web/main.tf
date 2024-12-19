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
            - hugo --gc --minify
      artifacts:
        baseDirectory: public
        files:
          - '**/*'
      cache:
        paths:
          - $${HUGO_CACHEDIR}/**/*
          - $${NPM_CONFIG_CACHE}/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    
  }
}