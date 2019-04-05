# CPRUVOST DOCKERFILE PROJECT
# --------------------------
#
# Dockerfile template for all tools needed in Infra As Code Automation 
#
# Oracle Instant Client 18.3 : sqlplus, imp, exp, impdp, expdp
# Usefull Tools Last version : jq, unzip, curl, wget
# Terraform v0.11.13
# OCI CLI Last Version
# OpenJdk 8
# Oracle Sqlcl 18.4
# Vault 0.11.6
# Kubectl 1.13.2
# Helm
#
# TO DO LIST : put variables for version of products.
#
# HOW TO BUILD THIS IMAGE
# -----------------------
#
# Run:
#      $ docker build -t yourgitaccount/infraascode .
#
#
FROM oraclelinux:7-slim

RUN mkdir /devops
WORKDIR /devops

# Oracle Instant Client 18.3
RUN  curl -o /etc/yum.repos.d/public-yum-ol7.repo https://yum.oracle.com/public-yum-ol7.repo && \
     yum-config-manager --enable ol7_oracle_instantclient && \
     yum -y install oracle-instantclient18.3-basic oracle-instantclient18.3-devel oracle-instantclient18.3-sqlplus oracle-instantclient18.3-tools && \
     rm -rf /var/cache/yum && \
     echo /usr/lib/oracle/18.3/client64/lib > /etc/ld.so.conf.d/oracle-instantclient18.3.conf && \
     ldconfig

#Usefull Tools Last Version
RUN yum -y install jq unzip curl wget

#Terraform v0.11.13
RUN wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip && \
    unzip ./terraform_0.11.13_linux_amd64.zip -d /usr/local/bin/ && \
    rm ./terraform_0.11.13_linux_amd64.zip

#OCI CLI Last Version
RUN yum install -y yum-utils && \
    yum-config-manager --enable *EPEL && \
    yum install -y python36 && \ 
    yum -y install gcc libffi-devel python-devel openssl-devel && \
    yum -y install python-pip && \
    pip install --upgrade pip && \
    pip install oci-cli

#Open Jdk8
RUN yum -y install java-1.8.0-openjdk-devel && rm -rf /var/cache/yum
ENV JAVA_HOME /usr/lib/jvm/java-openjdk

#Oracle Sqlcl 18.4
COPY sqlcl-18.4.0.007.1818.zip .
RUN unzip ./sqlcl-18.4.0.007.1818.zip && \
    rm -rf ./sqlcl-18.4.0.007.1818.zip 

#Sqlcl with oci option needs Oracle Instant Client
ENV LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib

#Vault 0.11.6
RUN mkdir vault && \
    wget https://releases.hashicorp.com/vault/0.11.6/vault_0.11.6_linux_amd64.zip && \
    unzip vault_0.11.6_linux_amd64.zip -d ./vault && \
    rm -rf vault_0.11.6_linux_amd64.zip

#Kubectl
COPY kubernetes.repo .
RUN  mv ./kubernetes.repo /etc/yum.repos.d/ && \
     yum -y install kubectl

#Helm
RUN mkdir helm && \
    curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.13.1-linux-amd64.tar.gz && \
    tar -zxvf helm-v2.13.1-linux-amd64.tar.gz -C ./helm && \
    chmod +x ./helm/linux-amd64/helm && \
    rm -rf helm-v2.13.1-linux-amd64.tar.gz

ENV PATH=$PATH:/usr/lib/oracle/18.3/client64/bin:/devops/sqlcl/bin:/devops/vault:/devops/helm/linux-amd64

COPY showtoolsversion.sh .
RUN  chmod +x showtoolsversion.sh

CMD ["./showtoolsversion.sh"]
