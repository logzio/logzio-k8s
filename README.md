This is a Logz.io Fluentd solution for Kubernetes.

## Fluentd DaemonSet

For Kubernetes, a DaemonSet ensures that some or all nodes run a copy of a pod. To collect logs, we'll use a Fluentd DaemonSet. Fluentd is flexible enough and has the proper plugins to distribute logs to different third parties, like Logz.io.

## DaemonSet Content

This repository contains the configurations to deploy Fluentd as a DaemonSet. The Docker container image also comes pre-configured for Fluentd to gather all logs from the Kubernetes node environment and append the proper metadata to the logs.

## Logging to Logz.io

### DaemonSet configuration

The DaemonSet yaml file has two environment variables. Fluentd uses these variables when the container starts.

| Environment variable | Description |
|----------------------|-------------|
|   LOGZIO_TOKEN       | [Logz.io account token](https://app.logz.io/#/dashboard/settings/general) |
|   LOGZIO_URL         | Logz.io listener url, If the account is in the EU region insert https://listener-eu.logz.io:8071. Otherwise, use https://listener.logz.io:8071. You can tell your account's region by checking your login URL - app.logz.io means you are in the US. app-eu.logz.io means you are in the EU |

For improved security you should store the variables using Kubernetes secrets:

```
kubectl create secret generic logzio-secrets --from-literal=logzio_token='MY_LOGZIO_TOKEN' --from-literal=logzio_url='MY_LOGZIO_URL' -n kube-system
```

Then you can easily install the DaemonSet on your cluster:

```
kubectl apply -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset-rbc.yaml
```

### Logz.io endpoint configuration

Here you can configure Logz.io Fluentd endpoint shipping behavior.

| Variable | Description | Default |
|------------------|----------------------------|---------|
| endpoint_url | The url to Logz.io input | `#{ENV['LOGZIO_URL']}?token=#{ENV['LOGZIO_TOKEN']}`
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
