# Deployment Guide - Vercel

## ✅ Completed Steps

### 1. GitHub Repository
- ✅ Repository created: https://github.com/hakinz0110/wealthstoreweb
- ✅ Code pushed with web build included
- ✅ `.env.example` created for reference
- ✅ `vercel.json` configured

### 2. Supabase Configuration
- ✅ Site URL updated to: `https://wealthstoreweb.com`
- ✅ Redirect URLs added:
  - `https://wealthstoreweb.com/**`
  - `https://www.wealthstoreweb.com/**`

## 🚀 Next Steps

### 3. Hostinger DNS Configuration
1. Log into Hostinger
2. Go to your domain: `wealthstoreweb.com`
3. Navigate to DNS/DNS Records section
4. Add these records:

```
Type: A
Name: @ (or leave blank)
Value: 76.76.21.21
TTL: Auto or 3600

Type: CNAME
Name: www
Value: cname.vercel-dns.com
TTL: Auto or 3600
```

### 4. Vercel Deployment
1. Go to https://vercel.com
2. Click "Add New" → "Project"
3. Import from GitHub: `hakinz0110/wealthstoreweb`
4. Configure project:
   - **Framework Preset:** Other
   - **Root Directory:** `.` (leave as is)
   - **Build Command:** (leave empty)
   - **Output Directory:** `build/web`
   - **Install Command:** (leave empty)

5. Add Environment Variables:
   ```
   SUPABASE_URL=https://zazbfusupfoxdhfgqmno.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   PAYSTACK_PUBLIC_KEY=pk_live_71fea23a174090b6c7daca1d7da9e3cc65de28be
   ```

6. Click "Deploy"

### 5. Add Custom Domain in Vercel
1. After deployment, go to Project Settings → Domains
2. Add domain: `wealthstoreweb.com`
3. Add domain: `www.wealthstoreweb.com`
4. Vercel will verify DNS records

### 6. Wait for DNS Propagation
- DNS changes can take 24-48 hours (usually faster)
- Check status: https://dnschecker.org

## 📝 Important Notes

- **Web build is pre-built** and included in the repo (`build/web`)
- **No build step needed** on Vercel - it serves static files
- **Environment variables** are for runtime configuration
- **Mobile apps** (Android/iOS) are not affected by this deployment

## 🔄 Future Updates

To update the web app:
1. Make changes locally
2. Run: `flutter build web --release`
3. Commit and push to GitHub
4. Vercel auto-deploys from GitHub

## 🔗 URLs After Deployment
- Production: https://wealthstoreweb.com
- Vercel URL: https://wealthstoreweb.vercel.app (auto-generated)
- GitHub: https://github.com/hakinz0110/wealthstoreweb
