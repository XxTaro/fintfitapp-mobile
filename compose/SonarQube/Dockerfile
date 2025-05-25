FROM sonarqube:lts-community

# Tornar o usuário root para poder instalar pacotes
USER root

# Atualizar e instalar dependências necessárias
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa \
    && curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.0-stable.tar.xz \
    && tar xf flutter_linux_3.29.0-stable.tar.xz \
    && rm -rf /opt/flutter \
    && mv flutter /opt/flutter \
    && rm flutter_linux_3.29.0-stable.tar.xz \
    && echo 'export PATH=$PATH:/opt/flutter/bin' >> ~/.bashrc \
    && apt-get clean 

# Definir o Flutter no PATH
ENV PATH="/opt/flutter/bin:${PATH}"

# Criar um usuário não-root
RUN addgroup --system sonar && adduser --system --ingroup sonar --shell /bin/bash sonar

RUN usermod -aG root sonar
