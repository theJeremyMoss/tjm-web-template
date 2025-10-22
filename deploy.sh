#!/bin/bash

# Reusable Website Deployment Script
# Usage: ./deploy.sh [aws-profile] [--dry-run]
# CloudFront Distribution ID: Set CLOUDFRONT_DIST_ID environment variable or script will prompt

set -e  # Exit on any error

# PROJECT CONFIGURATION - Update these values for your project
PROJECT_NAME="theJeremyMoss.com"
DOMAIN_NAME="thejeremymoss.com"
BUCKET_NAME="s3-tjm-website"
BUCKET_PATH=""      # Optional bucket path 
DEFAULT_PROFILE="personal-prod"

# EXCLUDE PATTERNS
# Files to exclude from deployment
EXCLUDE_FILES=(
    "README.md"
    "deploy.sh" 
    "screenshot.png"
    ".gitignore"
    "*.bak"
    "*.tmp"
)

# Directories to exclude from deployment
EXCLUDE_DIRECTORIES=(
    ".git/"
    "node_modules/"
)

# Get parameters
AWS_PROFILE=${1:-$DEFAULT_PROFILE}
DRY_RUN=${2:-""}

# Get CloudFront Distribution ID
get_cloudfront_id() {
    # Check if provided as environment variable
    if [ -n "$CLOUDFRONT_DIST_ID" ]; then
        echo -e "${GREEN}✅ Using CloudFront Distribution ID from environment variable${NC}"
        return 0
    fi
    
    # Prompt user for CloudFront Distribution ID
    echo -e "${YELLOW}CloudFront Distribution ID is required for deployment.${NC}"
    echo -e "${BLUE}You can find this in AWS Console > CloudFront > Distributions${NC}"
    echo ""
    read -p "Enter CloudFront Distribution ID: " CLOUDFRONT_DIST_ID
    
    # Validate input
    if [ -z "$CLOUDFRONT_DIST_ID" ]; then
        echo -e "${RED}❌ CloudFront Distribution ID is required.${NC}"
        echo -e "${YELLOW}Tip: You can also set it as an environment variable:${NC}"
        echo -e "${YELLOW}export CLOUDFRONT_DIST_ID=your-distribution-id${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ CloudFront Distribution ID set: ${YELLOW}$CLOUDFRONT_DIST_ID${NC}"
    echo ""
}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}🚀 $PROJECT_NAME Deployment${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo -e "AWS Profile: ${YELLOW}$AWS_PROFILE${NC}"
    if [ -n "$BUCKET_PATH" ]; then
        echo -e "S3 Bucket: ${YELLOW}s3://$BUCKET_NAME/$BUCKET_PATH${NC}"
    else
        echo -e "S3 Bucket: ${YELLOW}s3://$BUCKET_NAME${NC}"
    fi
    echo -e "Domain: ${YELLOW}$DOMAIN_NAME${NC}"
    if [ "$DRY_RUN" = "--dry-run" ]; then
        echo -e "${PURPLE}🔍 DRY RUN MODE - No actual changes will be made${NC}"
    fi
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}❌ AWS CLI is not installed. Please install it first.${NC}"
        exit 1
    fi
    
    # Check if AWS profile exists
    if ! aws configure list-profiles | grep -q "^$AWS_PROFILE$"; then
        echo -e "${RED}❌ AWS profile '$AWS_PROFILE' not found.${NC}"
        echo -e "${YELLOW}Available profiles:${NC}"
        aws configure list-profiles
        exit 1
    fi
    
    # Check if we're in the right directory
    if [ ! -f "index.html" ]; then
        echo -e "${RED}❌ Please run this script from the project root directory.${NC}"
        echo -e "${YELLOW}Expected file: index.html${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
}

# Function to upload files to S3
upload_to_s3() {
    # Determine S3 destination path
    local s3_destination="s3://$BUCKET_NAME"
    if [ -n "$BUCKET_PATH" ]; then
        s3_destination="$s3_destination/$BUCKET_PATH"
    fi
    
    echo -e "${BLUE}📤 Uploading website content to S3...${NC}"
    echo -e "${BLUE}   Source: Current directory${NC}"
    echo -e "${BLUE}   Destination: $s3_destination${NC}"
    
    if [ "$DRY_RUN" = "--dry-run" ]; then
        echo -e "${PURPLE}🔍 DRY RUN: Would upload current directory to $s3_destination${NC}"
        return 0
    fi
    
    # Build exclude arguments for AWS CLI
    local exclude_args=()
    for file in "${EXCLUDE_FILES[@]}"; do
        exclude_args+=(--exclude "$file")
    done
    for dir in "${EXCLUDE_DIRECTORIES[@]}"; do
        exclude_args+=(--exclude "$dir*")
    done
    
    # Upload static assets with long cache (everything except HTML/JSON)
    aws s3 sync . "$s3_destination" \
        --profile $AWS_PROFILE \
        --delete \
        --cache-control "public, max-age=31536000" \
        --exclude "*.html" \
        --exclude "*.json" \
        "${exclude_args[@]}"
    
    # Upload HTML and JSON files with shorter cache for freshness
    aws s3 sync . "$s3_destination" \
        --profile $AWS_PROFILE \
        --cache-control "public, max-age=0, must-revalidate" \
        --include "*.html" \
        --include "*.json" \
        "${exclude_args[@]}"
    
    echo -e "${GREEN}✅ Upload completed${NC}"
}

# Function to invalidate CloudFront cache
invalidate_cloudfront() {
    echo -e "${BLUE}🔄 Invalidating CloudFront cache...${NC}"
    
    if [ "$DRY_RUN" = "--dry-run" ]; then
        echo -e "${PURPLE}🔍 DRY RUN: Would invalidate CloudFront distribution $CLOUDFRONT_DIST_ID${NC}"
        return 0
    fi
    
    INVALIDATION_ID=$(aws cloudfront create-invalidation \
        --profile $AWS_PROFILE \
        --distribution-id $CLOUDFRONT_DIST_ID \
        --paths "/*" \
        --query 'Invalidation.Id' \
        --output text)
    
    echo -e "${GREEN}✅ CloudFront invalidation created: $INVALIDATION_ID${NC}"
}

# Function to deploy the website
deploy_website() {
    echo -e "${PURPLE}🎯 Deploying $PROJECT_NAME...${NC}"
    
    upload_to_s3
    invalidate_cloudfront
    echo ""
}

# Function to show deployment summary
show_summary() {
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo -e "${BLUE}Your website is available at:${NC}"
    echo -e "${YELLOW}  • https://$DOMAIN_NAME${NC}"
    echo ""
    echo -e "${YELLOW}⏳ CloudFront cache invalidation may take 5-15 minutes to complete.${NC}"
}

# Main execution
main() {
    print_header
    check_prerequisites
    get_cloudfront_id
    
    deploy_website
    show_summary
}

# Help function
show_help() {
    echo "Usage: $0 [aws-profile] [--dry-run]"
    echo ""
    echo "Arguments:"
    echo "  aws-profile    AWS profile to use (default: $DEFAULT_PROFILE)"
    echo "  --dry-run      Show what would be deployed without making changes"
    echo ""
    echo "CloudFront Distribution ID:"
    echo "  The script requires a CloudFront Distribution ID. You can provide it by:"
    echo "  1. Setting environment variable: export CLOUDFRONT_DIST_ID=your-id"
    echo "  2. The script will prompt you interactively if not set"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Deploy using default profile"
    echo "  $0 my-profile                         # Deploy using specific profile"
    echo "  $0 my-profile --dry-run               # Dry run with specific profile"
    echo "  CLOUDFRONT_DIST_ID=E123... $0         # Deploy with environment variable"
    echo ""
    echo "Configuration:"
    echo "  Project: $PROJECT_NAME"
    echo "  Domain: $DOMAIN_NAME"
    echo "  S3 Bucket: $BUCKET_NAME"
    if [ -n "$BUCKET_PATH" ]; then
        echo "  Bucket Path: $BUCKET_PATH"
    fi
    echo ""
    echo "Excluded files:"
    for file in "${EXCLUDE_FILES[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "Excluded directories:"
    for dir in "${EXCLUDE_DIRECTORIES[@]}"; do
        echo "  - $dir"
    done
}

# Check for help flag
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    show_help
    exit 0
fi

# Run main function
main