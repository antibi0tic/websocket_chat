#/srv/salt/docker.sls
docker:
  pkg.installed:
    - name: docker.io
  service.running:
    - name: docker
    - require:
      - pkg: docker
