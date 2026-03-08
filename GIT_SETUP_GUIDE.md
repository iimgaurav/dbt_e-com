# Git Setup & Push to GitHub - Step-by-Step Guide

## ✅ Files Created for CI/CD

The following files have been created to support GitHub Actions CI/CD:

1. **`.gitignore`** - Excludes dbt artifacts, venv, logs, and sensitive files from Git
2. **`.github/workflows/dbt-ci-cd.yml`** - GitHub Actions workflow that runs:
   - dbt parse (syntax validation)
   - dbt seed (load data)
   - dbt run (execute models)
   - dbt test (data quality checks)
   - dbt docs (generate documentation)
3. **`README.md`** - Project documentation
4. **`dbt_project/dbt_ecom/PROJECT_WALKTHROUGH.md`** - Detailed technical documentation

---

## 🚀 Push to GitHub - Step-by-Step

### Step 1: Initialize Git Repository (if not already done)

Open PowerShell and navigate to the project root:

```powershell
cd C:\Users\Navneet\Desktop\Project\e-com
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Step 2: Add All Files to Git

```powershell
git add .
```

### Step 3: Create Initial Commit

```powershell
git commit -m "Initial commit: dbt e-commerce project with CI/CD setup"
```

### Step 4: Add Remote Repository

```powershell
git remote add origin https://github.com/iimgaurav/dbt_e-com.git
```

### Step 5: Verify Remote Configuration

```powershell
git remote -v
# Should show:
# origin  https://github.com/iimgaurav/dbt_e-com.git (fetch)
# origin  https://github.com/iimgaurav/dbt_e-com.git (push)
```

### Step 6: Push to GitHub

```powershell
git branch -M main
git push -u origin main
```

When prompted, use your GitHub credentials (or personal access token).

---

## 🔑 Handling Credentials Securely

### ⚠️ IMPORTANT: Never Commit profiles.yml with Real Passwords

The `.gitignore` file is configured to **exclude** `profiles.yml`. However, you should verify:

1. **Check if profiles.yml is already committed**:
   ```powershell
   git log --all -- dbt_project/dbt_ecom/.dbt/profiles.yml
   ```
   
   If it shows up, remove it from history:
   ```powershell
   git rm --cached dbt_project/dbt_ecom/.dbt/profiles.yml
   git commit -m "Remove credentials from version control"
   ```

2. **For GitHub Actions**: Add secrets to your GitHub repository:
   - Go to: GitHub Repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Add these secrets:
     - `DB_USER` = `gau`
     - `DB_PASSWORD` = `gau@123`
     - `DB_NAME` = `e_com`
     - `DB_HOST` = `postgres` (for CI/CD, uses service name)

3. **Update profiles.yml for GitHub Actions** (optional, for security):
   ```yaml
   dbt_ecom:
     target: dev
     outputs:
       dev:
         type: postgres
         host: postgres
         port: 5432
         user: "{{ env_var('DB_USER') }}"
         password: "{{ env_var('DB_PASSWORD') }}"
         dbname: "{{ env_var('DB_NAME') }}"
         schema: dev_schema
         threads: 1
   ```

---

## ✅ Verify Push Success

1. **Check Git Status**:
   ```powershell
   git status
   # Should show: "On branch main, nothing to commit, working tree clean"
   ```

2. **View Remote URL**:
   ```powershell
   git remote -v
   ```

3. **Check GitHub Repository**:
   - Go to: https://github.com/iimgaurav/dbt_e-com
   - You should see all your files in the `main` branch

---

## 🔄 CI/CD Pipeline Details

### How It Works

When you push to GitHub:

1. **Trigger**: Push to `main` or `develop` branches, or create a pull request
2. **Environment**: GitHub Actions spins up a Linux container with:
   - Python 3.11
   - PostgreSQL 15 (service)
   - dbt-core 1.11.6
   - dbt-postgres 1.10.0
3. **Pipeline Steps**:
   - Checkout code
   - Setup Python & dependencies
   - Create `dev_schema` in Postgres
   - Run `dbt debug` (connection test)
   - Run `dbt parse` (syntax validation)
   - Run `dbt seed` (load data)
   - Run `dbt run` (execute models)
   - Run `dbt test` (data quality checks)
   - Run `dbt docs generate` (documentation)
   - Upload artifacts (logs, target/)
4. **PR Comments**: On pull requests, the workflow posts results as comments

### View CI/CD Results

- Go to: https://github.com/iimgaurav/dbt_e-com/actions
- Click on the latest workflow run
- View step-by-step execution logs
- Download artifacts (logs, dbt docs)

---

## 📋 Future Commits

After the initial push, use these commands for subsequent commits:

```powershell
# Make changes to files...

# Stage changes
git add .

# Commit with a message
git commit -m "Add new dbt models"

# Push to GitHub
git push origin main
```

---

## 🛠️ Useful Git Commands

```powershell
# View commit history
git log --oneline

# Check current branch
git branch

# Create a new branch for features
git checkout -b feature/new-model

# Switch back to main
git checkout main

# Merge feature branch
git merge feature/new-model

# View changes before committing
git diff

# Undo unstaged changes
git checkout -- <filename>

# Undo last commit (keep changes)
git reset --soft HEAD~1
```

---

## 🚨 Troubleshooting

### Issue: "fatal: remote origin already exists"
**Solution**:
```powershell
git remote remove origin
git remote add origin https://github.com/iimgaurav/dbt_e-com.git
```

### Issue: "Permission denied (publickey)"
**Solution**: Use personal access token instead of password
1. Create token: GitHub → Settings → Developer settings → Personal access tokens
2. Use token when prompted for password during `git push`

### Issue: CI/CD fails due to database connection
**Solution**: Ensure GitHub secrets are set (see "Handling Credentials Securely" section above)

### Issue: "profiles.yml accidentally committed"
**Solution**:
```powershell
git rm --cached dbt_project/dbt_ecom/.dbt/profiles.yml
git commit -m "Remove profiles.yml from tracking"
git push origin main
```

---

## ✨ Complete! Next Steps

1. ✅ Push to GitHub (follow Steps 1-6 above)
2. ✅ Verify CI/CD pipeline runs successfully
3. ✅ Monitor GitHub Actions for any failures
4. 📝 Create branches for new features
5. 🧪 Add data quality tests in `tests/` directory
6. 📊 Expand models in `models/` directories

**Your dbt project is now production-ready with automated CI/CD!** 🎉

---

**Need Help?**
- GitHub Docs: https://docs.github.com/en/get-started/using-git/about-git
- dbt Docs: https://docs.getdbt.com/
- GitHub Actions: https://docs.github.com/en/actions
