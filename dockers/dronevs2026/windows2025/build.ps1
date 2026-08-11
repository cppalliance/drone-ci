
# ltsc2025-based image. The ltsc2019-based image is cppalliance/dronevs2026:1
$image="cppalliance/dronevs2026:2"
echo "image is $image"
docker build -t $image .
