FROM ubuntu:22.04

COPY build/java_policy /etc
ENV DEBIAN_FRONTEND=noninteractive
RUN buildDeps='git libtool cmake python3-dev python3-pip libseccomp-dev curl ca-certificates gnupg' && \
    apt-get update && apt-get install -y python3 python3-pkg-resources gcc g++ $buildDeps && \
    apt-get install -y openjdk-11-jdk golang-go php-cli && \
    install -d -m 0755 /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs
RUN printf 'opcache.enable=1\nopcache.enable_cli=1\nopcache.jit=1205\nopcache.jit_buffer_size=64M\n' > /etc/php/8.1/cli/conf.d/10-opcache-jit.ini
RUN pip3 install --no-cache-dir psutil gunicorn flask requests idna
RUN cd /tmp && git clone -b newnew --depth 1 https://github.com/DCUSnSLab/DCU_Online_Judge_Judger.git

RUN cd /tmp/DCU_Online_Judge_Judger && mkdir build && cd build && cmake .. && make && make install && cd ../bindings/Python && pip3 install . && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/DCU_Online_Judge_Judger

RUN mkdir -p /code
RUN useradd -u 12001 compiler && useradd -u 12002 code && useradd -u 12003 spj && usermod -a -G code spj
#HEALTHCHECK --interval=5s --retries=3 CMD python3 /code/service.py
ADD server /code
WORKDIR /code
RUN gcc -shared -fPIC -o unbuffer.so unbuffer.c
EXPOSE 8080
ENTRYPOINT ["/bin/bash", "/code/entrypoint.sh"]
#ENTRYPOINT /code/entrypoint.sh
