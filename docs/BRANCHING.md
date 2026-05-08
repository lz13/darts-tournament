# Branching Strategy

## Branches
| Branch       | Purpose                           | Deploy Target                    |
|--------------|-----------------------------------|----------------------------------|
| `develop`    | Active development, local testing | None (local only)                |
| `staging`    | Pre-production testing, QA        | Staging server (178.128.199.154) |
| `production` | Production-ready code             | Production server (future)       |

---

## Workflow
### 1. Develop Features
```bash
git checkout develop
git pull origin develop

# Make changes, test locally
git add .
git commit -m "Implement feature X"
git push origin feature/tournament-model
```

### 2. Create Pull Request to Develop
- Go to GitHub repository 
- Create PR: `feature/tournament-model` -> `develop`
- Review changes, ensure tests pass
- Merge PR

### 3. Deploy to Staging (via PR)

- Create PR on GitHub: `develop` -> `staging`
- Review changes, ensure tests pass
- Merge PR

- Or do it manually:
```bash
git checkout staging
git merge develop
git push origin staging

# Deploy from staging branch
kamal deploy
```

### 4. Promote to Production

- Create PR on GitHub: staging → main
- Final review, merge
- Production deploy (future)

```bash
# After staging is verified
git checkout main
git merge staging
git push origin main
```
---
## Pull Request Rules

1. develop → staging: Must be reviewed before merging
2. staging → main: Must be reviewed before merging
3. Feature branches → develop: Review optional for solo work, recommended

---
## Deployment Commands

### Staging
```bash
git checkout staging
git merge develop
git push origin staging
kamal deploy

# Database Operations (Staging)
kamal app exec "bin/rails db:migrate"

# Check logs
kamal logs

# Open console
kamal console
```
---

## Important Notes
- Always test locally on develop before creating PR to staging
- Never commit .kamal/secrets or config/master.key
- Migrations must be backward-compatible when possible
- Database is shared across staging deployments
