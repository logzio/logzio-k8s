This is a Logz.io Fluentd solution for Kubernetes.

## Fluentd DaemonSet

For Kubernetes, a DaemonSet ensures that some or all nodes run a copy of a pod. To collect logs, we'll use a Fluentd DaemonSet. Fluentd is flexible enough and has the proper plugins to distribute logs to different third parties, like Logz.io.

## DaemonSet Content

This repository contains the configurations to deploy Fluentd as a DaemonSet. The Docker container image also comes pre-configured for Fluentd to gather all logs from the Kubernetes node environment and append the proper metadata to the logs.

## Logging to Logz.io

### DaemonSet configuration

Save your Logz.io shipping credentials as a Kubernetes secret.

Replace `<<SHIPPING-TOKEN>>` with the [token](https://app.logz.io/#/dashboard/settings/general) of the account you want to ship to.

Replace <<LISTENER-HOST>> with your region’s listener host (for example, listener.logz.io). For more information on finding your account’s region, see Account region.

```
kubectl create secret generic logzio-logs-secret --from-literal=logzio-log-shipping-token='<<ACCOUNT-TOKEN>>' --from-literal=logzio-log-listener='https://<<LISTENER-HOST>>:8071' -n kube-system
```

Then you can easily install the DaemonSet on your cluster:

```
kubectl apply -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset-rbc.yaml
```

### Logz.io endpoint configuration

Here you can configure Logz.io Fluentd endpoint shipping behavior.

| Variable | Description | Default |
|------------------|----------------------------|---------|
| endpoint_url | The url to Logz.io input | `#{ENV['LOGZIO_LOG_LISTENER']}?token=#{ENV['LOGZIO_LOG_SHIPPING_TOKEN']}`
| output_include_time | To append a timestamp to your logs when they're processed, `true`. Otherwise, `false`. | `true`
| buffer_type |  Specifies which plugin to use as the backend | `file`
| buffer_path | Path of the buffer | `/var/log/Fluentd-buffers/stackdriver.buffer`
| buffer_queue_full_action | Controls the behavior when the queue becomes full | `block`
| buffer_chunk_limit | Maximum size of a chunk allowed | `2M`
| buffer_queue_limit | Maximum length of the output queue | `6`
| flush_interval | Interval, in seconds, to wait before invoking the next buffer flush | `5s`
| max_retry_wait | Maximum interval, in seconds, to wait between retries | `30s`
| num_threads | Number of threads to flush the buffer | `2`

### Disable systemd input
If you don't setup systemd in the container, fluentd shows following messages by default configuration.

 ```
[warn]: #0 [in_systemd_bootkube] Systemd::JournalError: No such file or directory retrying in 1s
[warn]: #0 [in_systemd_kubelet] Systemd::JournalError: No such file or directory retrying in 1s
[warn]: #0 [in_systemd_docker] Systemd::JournalError: No such file or directory retrying in 1s
```

 You can suppress these messages by setting `disable` to `FLUENTD_SYSTEMD_CONF` environment variable in your kubernetes configuration.
