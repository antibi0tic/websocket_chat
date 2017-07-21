install_docker-py:
  pip.installed:
    - name: docker-py
    - upgrade: True

restart_minion:
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - pip: install_docker-py