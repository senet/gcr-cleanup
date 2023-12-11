#!/bin/bash

# Function to retrieve and filter image list
get_images() {
  local filter="$1"
  gcloud container images list --repository gcr.io/$project $filter | grep -v NAME | cut -d ' ' -f 1
}

# Function to delete image and its tags
delete_image() {
  local image="$1"
  local digest="$2"

  echo "Deleting image: $image@sha256:$digest"
  gcloud container images untag "$image" --quiet
  gcloud container images delete "$image@sha256:$digest" --quiet
}

# Function to process image tags
process_tags() {
  local image="$1"
  local retention_period="$2"

  local image_tags=$(gcloud container images list-tags "$image" --format="get(tags)")

  for tag in $image_tags; do
    local timestamp=$(gcloud container images list-tags "$image:$tag" --format="get(timestamp.day)")

    local timestamp_epoch=$(date -d "$timestamp days ago" +%s)

    if ((timestamp_epoch < retention_period)); then
      echo "Deleting tag: $image:$tag"
      gcloud container images untag "$image:$tag" --quiet
    else
      echo "Image tag: $image:$tag is newer than $retention_period days. Skipping deletion."
    fi
  done
}

# Script parameters
project="$1"
retention_period="$2"
dev_retention_period="${3:-}"
dev_tag_pattern="${4:-}"

# Get all images
images=$(get_images)

# Cleanup untagged images older than a day
untagged_images=$(get_images "--filter='-tags:*'")
for image in $untagged_images; do
  delete_image "$image" "$(gcloud container images list-tags "$image" --format="get(digest)")"
done

# Process remaining images
for image in $images; do
  echo "Processing image: $image"

  process_tags "$image" "$retention_period"

  if [[ -n "$dev_retention_period" && -n "$dev_tag_pattern" ]]; then
    # Process Dev build images
    dev_build_tags=$(gcloud container images list-tags "$image" --filter="$dev_tag_pattern" --format="get(tags)")
    for tag in $dev_build_tags; do
      local timestamp=$(gcloud container images list-tags "$image:$tag" --format="get(timestamp.day)")
      local timestamp_epoch=$(date -d "$timestamp days ago" +%s)

      if ((timestamp_epoch < dev_retention_period)); then
        echo "Deleting Dev build tag: $image:$tag"
        delete_image "$image" "$(gcloud container images list-tags "$image:$tag" --format="get(digest)")"
      fi
    done
  fi
done

echo "Cleanup completed!"
