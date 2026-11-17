# Isolated nested-Docker architecture

```text
VPS 167 host Docker
└── mgs-dind (Docker-in-Docker engine)
    ├── dind-symfony-demo-app (PHP 8.4 + Symfony 7.4)
    └── dind-symfony-demo-db (PostgreSQL 16)
```

The two services attach only to the Compose network `dind-symfony-postgres-private`, declared with `internal: true`. The application connects to `db:5432`; PostgreSQL has no published port. Neither service declares a host `ports:` mapping, and this repository defines no reverse proxy, webhook, SGE/Kajy route, or external app URL.

The named volume `dind-symfony-postgres-data` stores the fictional PostgreSQL sample rows in the inner Docker engine. The outer Docker host sees the `mgs-dind` container; the app and database are listed by running Docker commands inside that container.

GitHub is the public source for the two repositories. A manual clone from inside `mgs-dind` and a local Ansible playbook drive the inner Compose deployment. A future GitHub webhook or URL exposure would need a separate design and is intentionally absent from this demo.
