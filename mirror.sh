#!/bin/bash 

GHCR_REGISTRY=$1

jq -r '.[] | .[]' mappings.json | while read -r IMAGE; do
    # image에서 `/`를 기준으로 나눠서 이름을 추출
    IMAGE_NAME_TAG=$(echo "$IMAGE" | cut -d'/' -f2)

    # 이미 mirror된 이미지가 있는지 확인하고 있으면 건너뜀
    GHRC_IMAGE="$GHCR_REGISTRY/$IMAGE_NAME_TAG"

    if [ "$(docker manifest inspect "$GHRC_IMAGE" 2>/dev/null)" ]; then
        echo "Image $GHRC_IMAGE already exists, skipping..."
        continue
    fi

    # dockerhub에서 이미지를 가져옴
    docker pull "$IMAGE" || { echo "Failed to pull $IMAGE"; continue; }
    
    # dockerhub에서 가져온 이미지를 ghcr로 푸시
    docker tag "$IMAGE" "$GHRC_IMAGE" || { echo "Failed to tag $IMAGE"; continue; }
    docker push "$GHRC_IMAGE" || { echo "Failed to push $GHRC_IMAGE"; continue; }
done

