FROM jenkins/jenkins:lts
USER root

RUN apt-get update && apt-get install -y docker.io curl git

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

RUN groupadd -f docker && usermod -aG docker jenkins

RUN printf '#!/bin/bash\nchmod 777 /var/run/docker.sock\nexec /usr/bin/tini -- /usr/local/bin/jenkins.sh "$@"' \
    > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
