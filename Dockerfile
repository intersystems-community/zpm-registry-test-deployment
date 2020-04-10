FROM intersystemsdc/iris-community:2020.1.0.209.0-zpm

USER root

WORKDIR /opt/irisapp
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} .

USER irisowner

COPY  Installer.cls .
COPY irissession.sh /
SHELL ["/irissession.sh"]

RUN \
  do $SYSTEM.OBJ.Load("Installer.cls", "ck") \
  set sc = ##class(App.Installer).setup() \
  zn "IRISAPP" \
  zpm "install zpm-registry"


# bringing the standard shell back
SHELL ["/bin/bash", "-c"]