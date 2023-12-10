# gcr-cleanup

GCR currently doesn't offer a built-in lifecycle management feature for container images like AWS ECR. While Artifact Registry, which replaces GCR, doesn't have this feature yet, it's planned for the future. This script can be used to clean up images older than x days to minimize GCS cost.