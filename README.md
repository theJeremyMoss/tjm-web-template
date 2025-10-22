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
# Deploy with default profile (will prompt for CloudFront ID)
./deploy.sh

# Deploy with environment variable
export CLOUDFRONT_DIST_ID=EXXXXXXXXXXXXX
./deploy.sh

# Deploy with specific AWS profile
./deploy.sh your-aws-profile

# Deploy with environment variable and specific profile
CLOUDFRONT_DIST_ID=EXXXXXXXXXXXXX ./deploy.sh your-aws-profile

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
- **Default AWS Profile**: personal-prod

### CloudFront Distribution ID

The deployment script requires your CloudFront Distribution ID. You can provide it in two ways:

1. **Environment Variable** (recommended for reuse):
   ```bash
   export CLOUDFRONT_DIST_ID=EXXXXXXXXXXXXX
   ./deploy.sh
   ```

2. **Interactive Prompt**: The script will ask you to enter it if not set as an environment variable.

**Finding your CloudFront Distribution ID:**
- Go to [AWS Console > CloudFront](https://console.aws.amazon.com/cloudfront/)
- Find your distribution for the domain
- Copy the Distribution ID (format: E123ABCD456EFG)

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
