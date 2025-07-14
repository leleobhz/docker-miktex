FROM debian:bookworm

LABEL Description="Dockerized MiKTeX, Debian Bookworm"
LABEL Vendor="Christian Schenk"
LABEL Version="latest"

ARG DEBIAN_FRONTEND=noninteractive

ARG user=miktex
ARG group=miktex
ARG uid=1000
ARG gid=1000

ARG miktex_home=/var/lib/miktex
ARG miktex_work=/miktex/work
ARG miktex_packages=/miktex/packages

RUN groupadd -g ${gid} ${group} \
    && useradd -d "${miktex_home}" -u ${uid} -g ${gid} -m -s /bin/bash ${user}

RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
           make \
           apt-transport-https \
           ca-certificates \
           curl \
           dirmngr \
           ghostscript \
           gnupg \
           gosu \
           perl

RUN curl -fsSL https://miktex.org/download/key | gpg --dearmor -o /usr/share/keyrings/miktex.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/miktex.gpg] https://miktex.org/download/debian bookworm universe" | tee /etc/apt/sources.list.d/miktex.list

RUN    apt-get update -y \
    && apt-get install -y --no-install-recommends \
           miktex

USER ${user}

RUN    miktexsetup finish \
    && initexmf --set-config-value=[MPM]AutoInstall=1 \
    && initexmf --set-config-value=[MPM]LocalRepository="${miktex_packages}" \
    && miktex packages update \
    && miktex packages install amsfonts

VOLUME [ "${miktex_home}" ]

WORKDIR ${miktex_work}

USER root
    
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

ENV PATH=/var/lib/miktex/bin:${PATH}

CMD ["bash"]
