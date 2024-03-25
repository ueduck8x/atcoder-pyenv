ARG PYTHON_VERSION=3.11.4
FROM python:${PYTHON_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

ARG WORKDIR=/project/src
WORKDIR ${WORKDIR}

SHELL ["/bin/bash", "-c"]
RUN chsh -s /bin/bash

RUN rm -rf /var/lib/apt/lists/*
RUN apt update
RUN apt install -y \
    sudo \
    git \
    vim \
    time \
    locales && \
    localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
RUN rm -rf /var/lib/apt/lists/*

ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
ENV TZ=Asia/Tokyo
RUN echo $TZ > /etc/timezone

ARG USERNAME=atcoder-user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# install python packages
RUN pip install --upgrade pip
COPY ./requirements.txt /tmp/requirements.txt
COPY ./mypy.ini /tmp/mypy.ini
RUN pip install -r /tmp/requirements.txt

# atcoder-cli install
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
    && apt install -y nodejs \
    && npm install --global atcoder-cli

# atcoder env setting
COPY ./src/templates/ /home/$USERNAME/.config/atcoder-cli-nodejs/
RUN sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/
RUN sudo -u $USERNAME acc config default-template py
RUN sudo -u $USERNAME acc config default-task-choice next
COPY ./.bash_aliases /home/$USERNAME/.bash_aliases
RUN source /home/$USERNAME/.bashrc

CMD ["/bin/bash"]
