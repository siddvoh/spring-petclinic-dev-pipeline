FROM nginx:alpine

# Bake the reverse-proxy config into the image instead of bind-mounting it.
# Bind mounts of workspace files break when compose is launched from inside the
# Jenkins container (the host Docker daemon can't see the Jenkins workspace path).
COPY default.conf /etc/nginx/conf.d/default.conf
