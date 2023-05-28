FROM public.ecr.aws/apparentorder/reweb as reweb

FROM vault:latest

COPY --from=reweb /reweb /reweb

ENV VAULT_ADDR="http://0.0.0.0:8200"

COPY config/vault-server.hcl /vault/config/

ENV REWEB_APPLICATION_EXEC /usr/bin/dumb-init -- /bin/vault server -config /vault/config/vault-server.hcl
ENV REWEB_APPLICATION_PORT 8200
ENV REWEB_WAIT_CODE 200
ENV REWEB_WAIT_PATH /v1/sys/health

ENTRYPOINT ["/reweb"]
