
# gcr-cleanup

GCR currently lacks a built-in feature for container image lifecycle management, unlike AWS ECR. While Artifact Registry, which will replace GCR, doesn't currently offer this functionality, it's planned for the future. This script helps you minimize GCS storage costs by cleaning up container images older than a specified number of days.

## How to use

#### Clone the repository:
`git clone https://github.com/your-username/gcr-cleanup.git`

#### Run the script:
`./gcr-cleanup.sh <PROJECT_NAME> <RETENTION_DAYS>`

#### Arguments:
`<PROJECT_NAME>`: Your Google Cloud project ID.
`<RETENTION_DAYS>`: The number of days to retain images. Images older than this threshold will be deleted.

Example: `./gcr-cleanup.sh my-project 30`

This will delete all images in your project's GCR repository that are older than 30 days.

#### Note: Make sure you have the necessary permissions to delete images in your GCR repository.