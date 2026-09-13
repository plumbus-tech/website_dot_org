FROM pandoc/core:3.7.0.2-ubuntu

# git lets actions/checkout clone (with submodules) inside container jobs.
RUN apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY bin /opt/website_dot_org/bin
COPY share /opt/website_dot_org/share
RUN ln -s /opt/website_dot_org/bin/website_dot_org /usr/local/bin/website_dot_org

WORKDIR /site
ENTRYPOINT ["website_dot_org"]
CMD ["build"]
