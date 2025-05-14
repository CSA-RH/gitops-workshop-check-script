# RH Gitops workshop check script

A small bash script that checks who has completed which steps of the gitops workshop

🔧 Example Usage

Default (20 users, default domain):

```bash
./check_workshop.sh
```

With 30 users:

```bash
./check_workshop.sh 30
```

With 30 users and a custom base domain:

```bash
./check_workshop.sh 30 apps.cluster-abc123.abc123.sandbox9999.opentlc.com
```
