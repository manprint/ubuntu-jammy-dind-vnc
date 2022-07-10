FROM kasmweb/core-ubuntu-jammy:1.11.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

RUN apt update && \
	apt upgrade -y && \
	apt install -y sudo \
		openssh-server nano wget gdebi-core \ 
		curl geany tree git gedit gpg && \
	curl -fsSL https://get.docker.com -o get-docker.sh && \
	sh get-docker.sh && \
	rm -rf get-docker.sh && \
	apt-get clean && \
	apt-get autoremove -y && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt update && \
	apt upgrade -y && \
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
	install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
	sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
	apt install apt-transport-https && \
	sudo apt update && \
	apt install -y code && \
	apt-get clean && \
	apt-get autoremove -y && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt update && \
	apt upgrade -y && \
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
	echo "y" | gdebi google-chrome-stable_current_amd64.deb && \
	rm -rf gdebi google-chrome-stable_current_amd64.deb && \
	apt-get clean && \
	apt-get autoremove -y && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt update && \
	apt upgrade -y && \
	apt install -y tilix \
		ca-certificates htop gnupg apt-utils locales openssl xz-utils filezilla fuse rsync \
		pigz netstat-nat w3m iputils-ping iproute2 python3 python3-pip unzip zip evince \
		busybox p7zip-full software-properties-common make build-essential retext \
		lsb-release iptables telnet bash-completion net-tools tzdata abiword gnumeric parcellite && \
	apt-get clean && \
	apt-get autoremove -y && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
	apt-get install -y gnupg software-properties-common curl && \
	curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && \
	sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
	sudo apt-get update && sudo apt-get install terraform && \
	apt-get clean && \
	apt-get autoremove -y && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime && \
	dpkg-reconfigure -f noninteractive tzdata

RUN pip3 install --no-cache-dir runlike && \
	curl https://rclone.org/install.sh | sudo bash && \
	echo "user_allow_other" > /etc/fuse.conf && chmod 775 /etc/fuse.conf

RUN git clone https://github.com/facebook/zstd.git /tmp/zstd && \
	cd /tmp/zstd && make && cd programs && cp -a zstd /usr/local/bin && \
	rm -rf /tmp/zstd

RUN apt-get update && \
	apt-get install -y thunar-archive-plugin && \
	wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb && \
	apt install -y ./dbeaver-ce_latest_amd64.deb && \
	rm -rf dbeaver-ce_latest_amd64.deb && \
	curl -1sLf 'https://dl.cloudsmith.io/public/asbru-cm/release/cfg/setup/bash.deb.sh' | sudo -E bash && \
	sudo apt install -y asbru-cm && \
	apt-get clean && \
	apt-get autoremove -y && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN userdel kasm-user && \
	addgroup --gid 1000 kasm-user && \
	useradd -m -s /bin/bash -g kasm-user -G sudo,root,docker -u 1000 kasm-user && \
	/usr/bin/ssh-keygen -A && \
	mkdir -vp /run/sshd && \
	mkdir -vp /var/run/sshd && \
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	sed -i 's/#StrictModes yes/StrictModes no/' /etc/ssh/sshd_config && \
	sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
	sed -i 's/PrintMotd no/PrintMotd yes/' /etc/ssh/sshd_config && \
	sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
	echo "root:password" | chpasswd && \
	echo "kasm-user:password" | chpasswd && \
	echo "kasm-user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY assets/generate_container_user /dockerstartup/generate_container_user

COPY assets/kasm_default_profile.sh /dockerstartup/kasm_default_profile.sh
COPY assets/custom_startup.sh ${STARTUPDIR}/custom_startup.sh
RUN chmod +x ${STARTUPDIR}/custom_startup.sh

COPY --chown=kasm-user:kasm-user assets/desktop_shortcut /opt/shortcut

######### End Customizations ###########

RUN chown kasm-user:kasm-user $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R kasm-user:kasm-user $HOME

USER kasm-user