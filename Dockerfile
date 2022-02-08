FROM golang:1.17.6

#Install basics
RUN apt-get update && apt-get install -y \
    bash-completion \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

#Install docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli

#Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    mv kubectl /usr/local/bin && \
    chmod +x /usr/local/bin/kubectl

#Install kubectl bash completion
RUN echo 'source /usr/share/bash-completion/bash_completion' >>~/.bashrc && echo 'source <(kubectl completion bash)' >>~/.bashrc

#Install kubebuilder
RUN curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH) && \
    chmod +x kubebuilder && mv kubebuilder /usr/local/bin/

#Install kubebuilder bash completion
RUN kubebuilder completion bash

#Clean apt-get
RUN apt-get purge curl gnupg lsb-release -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT [ "bash", "-c", "echo Login to DockerHub && cat /root/docker.pwd | docker login -u $USER --password-stdin && /bin/bash" ]
