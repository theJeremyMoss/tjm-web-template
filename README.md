# theJeremyMoss.com

Personal website with animated particle background.

## Tech Stack

- **Framework**: Tailwind CSS
- **Animation**: tsParticles
- **Font**: IBM Plex Sans
- **Hosting**: AWS S3 + CloudFront
- **Domain**: thejeremymoss.com

## Quick Start

### Local Development
```bash
# Start local server
python -m http.server 8000

# Open in browser
open http://localhost:8000
```

### Deploy to AWS
```bash
# Deploy with default profile
./deploy.sh

# Deploy with specific AWS profile
./deploy.sh your-aws-profile

# Preview changes (dry run)
./deploy.sh your-aws-profile --dry-run
```

## Project Structure

```
/
├── index.html        # Main landing page
├── resume.html       # Resume page
├── 404.shtml         # Custom 404 page
├── jm-pro.png        # Profile photo
├── ico/              # Favicon assets
├── deploy.sh         # AWS deployment script
├── screenshot.png    # Preview image
└── README.md         # Documentation
```

## Deployment Configuration

- **Domain**: thejeremymoss.com
- **S3 Bucket**: s3-tjm-website
- **CloudFront ID**: E18FP85I533X35
- **Default AWS Profile**: personal-prod

### Excluded from Deployment
- `README.md`
- `deploy.sh`
- `screenshot.png`
- `.gitignore`

### AWS Requirements
- AWS CLI installed and configured
- S3 bucket read/write/delete permissions
- CloudFront invalidation permissions

## Features

- Responsive design
- Animated particle background
- Fade-in animations
- Social media links
- Google Analytics integration

---

**Live Site**: https://thejeremymoss.com
