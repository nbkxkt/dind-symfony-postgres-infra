# DIND Symfony + PostgreSQL infrastructure

This repository holds Compose, Ansible and the architecture for the companion public app repository `nbkxkt/dind-symfony-postgres-demo`.

## Scope

- Run Compose and Ansible inside the `mgs-dind` container on VPS 167; Compose talks to that container's own nested Docker daemon.
- Keep Symfony and PostgreSQL inside the nested Docker engine.
- Use an `internal: true` network and no `ports:` mappings.
- Use only fictional seeded rows. Keep the generated runtime `infra/.env` inside the DIND checkout and out of Git.
- Do not add an external webhook, reverse proxy, SGE/Kajy URL, or public application route in this scope.

## Deployment inside `mgs-dind`

The `mgs-dind` image already provides Docker Compose v2. Install Ansible inside that DIND container when needed (the package is lost if the outer container is recreated):

```sh
docker exec mgs-dind apk add --no-cache ansible
docker exec mgs-dind ansible-playbook --version
docker exec mgs-dind docker compose version
```

Then clone both public repositories from within the DIND container:

```sh
mkdir -p /opt/dind-symfony-postgres
cd /opt/dind-symfony-postgres
git clone https://github.com/nbkxkt/dind-symfony-postgres-demo.git app
git clone https://github.com/nbkxkt/dind-symfony-postgres-infra.git infra
cd /opt/dind-symfony-postgres/infra
./scripts/create-env.sh
ansible-playbook ansible/deploy.yml
```

`create-env.sh` writes random values to a mode-0600 `.env` only on the DIND filesystem. It refuses to overwrite an existing environment. The root `.gitignore` excludes `.env`; do not copy this file into either public repository.

The playbook runs `docker compose config --quiet`, builds and starts the stack, waits for PostgreSQL and app healthchecks. The app healthcheck calls `/healthz` from inside the container and confirms that the sample table is readable. The app page at `/` reads the sample table. No host or outer-DIND port is opened for it.

To inspect the deployment from the host, use the `kajyroot` runbook to enter the nested engine with `docker exec mgs-dind docker ps -a`. This project deliberately does not configure or test an outside URL.
