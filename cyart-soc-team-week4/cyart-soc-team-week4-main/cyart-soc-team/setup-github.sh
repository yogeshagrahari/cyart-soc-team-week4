
echo "  cyart-soc-team — GitHub Setup Script"
echo "==========================================="

# Step 1: Initialize git repo (if not already)
git init
echo " Git initialized"

# Step 2: Set your identity (replace with your details)
git config user.name "SOC Analyst"
git config user.email "your-email@example.com"

# Step 3: Add all files
git add .
echo " All files staged"

# Step 4: Initial commit
git commit -m "feat: Add Week 4 — Advanced SOC Operations

- 01 Threat Hunting: T1078 hypothesis, Elastic queries, Velociraptor
- 02 SOAR Automation: PHI-001 playbook, CrowdSec integration
- 03 Post-Incident Analysis: 5 Whys RCA, Fishbone, MTTD/MTTR
- 04 Adversary Emulation: Caldera T1566/T1078/T1210 (91% detection)
- 05 Security Metrics: Elastic dashboard, executive report
- 06 Capstone: Metasploit Samba exploit, full SANS report

Attacker IP: 10.0.2.20 | Period: 30 Mar - 02 Apr 2026"

echo " Initial commit created"

# Step 5: Add GitHub remote (replace with your actual repo URL)
# git remote add origin https://github.com/YOUR_USERNAME/cyart-soc-team.git

# Step 6: Push to GitHub
# git branch -M main
# git push -u origin main

echo ""
echo " Next Steps:"
echo "  1. Create repo on GitHub: https://github.com/new"
echo "     Name: cyart-soc-team"
echo "     Visibility: Public"
echo ""
echo "  2. Run these commands:"
echo "     git remote add origin https://github.com/YOUR_USERNAME/cyart-soc-team.git"
echo "     git branch -M main"
echo "     git push -u origin main"
echo ""
echo "  3. Add screenshots to each section's screenshots/ folder"
echo "  4. Update hash values in chain-of-custody.md with real SHA256 hashes"
echo ""
echo " Setup complete! Repository is ready."
