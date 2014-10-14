{% from "oracle-java/map.jinja" import oracle_java with context %}

{% set version = salt['pillar.get']('oracle_java:lookup:version', None) %}
{% set set_default = salt['pillar.get']('oracle_java:lookup:set_default', True) %}

{% if grains.os_family == 'Debian' %}
java7_sources_list:
    pkgrepo.managed:
        - name: "deb http://ppa.launchpad.net/webupd8team/java/ubuntu {{ grains.oscodename }} main"
        - keyserver: keyserver.ubuntu.com
        - keyid: EEA14886
        - file: /etc/apt/sources.list.d/java_oracle.list
        - require_in:
            - pkg: java7_packages

# Install debconf-utils for checking debconf
debconf-utils:
    pkg.installed
{% endif %}

# Accept oracle java 7 license

{% if grains.os_family == 'Debian' %}
java7_read_license:
    cmd.run:
        - name: "echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections"
        - unless: 'debconf-get-selections | grep "shared/accepted-oracle-license-v1-1"'
        - require:
            - pkg: debconf-utils
        - require_in:
            - pkg: java7_packages

java7_see_license:
    cmd.run:
        - name: "echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections"
        - unless: 'debconf-get-selections | grep "shared/accepted-oracle-license-v1-1"'
        - require:
            - pkg: debconf-utils
        - require_in:
            - pkg: java7_packages
{% endif %}

java7_packages:
    pkg.installed:
        - pkgs:
            - {{ oracle_java.package_name }}
            {% if set_default %}
            - {{ oracle_java.set_default_package_name }}
            {% endif %}
        - require:
            - pkgrepo: java7_sources_list
