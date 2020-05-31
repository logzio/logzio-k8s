# logzio-k8s

For Kubernetes, a DaemonSet ensures that some or all nodes run a copy of a pod.
This implementation is uses a Fluentd DaemonSet to collect Kubernetes logs.
Fluentd is flexible enough and has the proper plugins to distribute logs to different third parties such as Logz.io.

The logzio-k8s image comes pre-configured for Fluentd to gather all logs from the Kubernetes node environment and append the proper metadata to the logs.

You have two options for deployment:

* [Default configuration <span class="sm ital">(recommended)</span>](#default-config)
* [Custom configuration](#custom-config)

<div id="default-config">

## Deploy logzio-k8s with default configuration

For most environments, we recommend using the default configuration.
However, you can deploy a custom configuration if your environment needs it.

### To deploy logzio-k8s

#### 1.  Store your Logz.io credentials

Save your Logz.io shipping credentials as a Kubernetes secret.

Replace `<<SHIPPING-TOKEN>>` with the [token](https://app.logz.io/#/dashboard/settings/general) of the account you want to ship to. <br>
Replace `<<LISTENER-HOST>>` with your region's listener host (for example, `listener.logz.io`).
For more information on finding your account's region,
see [Account region](https://docs.logz.io/user-guide/accounts/account-region.html).

```shell
kubectl create secret generic logzio-logs-secret \
--from-literal=logzio-log-shipping-token='<<SHIPPING-TOKEN>>' \
--from-literal=logzio-log-listener='https://<<LISTENER-HOST>>:8071' \
-n kube-system
```

#### 2.  Deploy the DaemonSet

For an RBAC cluster:

```shell
kubectl apply -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset-rbac.yaml
```

Or for a non-RBAC cluster:

```shell
kubectl apply -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset.yaml
```

#### 3.  Check Logz.io for your logs

Give your logs some time to get from your system to ours,
and then open [Kibana](https://app.logz.io/#/dashboard/kibana).

If you still don't see your logs,
see [log shipping troubleshooting](https://docs.logz.io/user-guide/log-shipping/log-shipping-troubleshooting.html).

</div>
<!-- tab:end -->


<!-- tab:start -->
<div id="custom-config">

## Deploy logzio-k8s with custom configuration

You can customize the configuration of the Fluentd container.
This is done using a ConfigMap that overwrites the default DaemonSet.

### To deploy logzio-k8s

#### 1.  Store your Logz.io credentials

Save your Logz.io shipping credentials as a Kubernetes secret.

Replace `<<SHIPPING-TOKEN>>` with the [token](https://app.logz.io/#/dashboard/settings/general) of the account you want to ship to. <br>
Replace `<<LISTENER-HOST>>` with your region's listener host (for example, `listener.logz.io`).
For more information on finding your account's region,
see [Account region](https://docs.logz.io/user-guide/accounts/account-region.html).

```shell
kubectl create secret generic logzio-logs-secret \
--from-literal=logzio-log-shipping-token='<<SHIPPING-TOKEN>>' \
--from-literal=logzio-log-listener='https://<<LISTENER-HOST>>:8071' \
-n kube-system
```

#### 2.  Configure Fluentd

Download either
the [RBAC DaemonSet](https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset-rbac.yaml)
or the [non-RBAC DaemonSet](https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset.yaml)
and open the file in your text editor.

Customize the integration environment variables configurations with the parameters shown below.

**Parameters**

| Parameter | Description |
|---|---|
| output_include_time | **Default**: `true` <br>  To append a timestamp to your logs when they're processed, `true`. Otherwise, `false`. |
| LOGZIO_BUFFER_TYPE | **Default**: `file` <br>  Specifies which plugin to use as the backend. |
| LOGZIO_BUFFER_PATH | **Default**: `/var/log/Fluentd-buffers/stackdriver.buffer` <br>  Path of the buffer. |
| LOGZIO_OVERFLOW_ACTION | **Default**: `block` <br>  Controls the behavior when the queue becomes full. |
| LOGZIO_CHUNK_LIMIT_SIZE | **Default**: `2M` <br>  Maximum size of a chunk allowed |
| LOGZIO_QUEUE_LIMIT_LENGTH | **Default**: `6` <br>  Maximum length of the output queue. |
| LOGZIO_FLUSH_INTERVAL | **Default**: `5s` <br>  Interval, in seconds, to wait before invoking the next buffer flush. |
| LOGZIO_RETRY_MAX_INTERVAL | **Default**: `30s` <br>  Maximum interval, in seconds, to wait between retries. |
| LOGZIO_FLUSH_THREAD_COUNT | **Default**: `2` <br>  Number of threads to flush the buffer. |
| LOGZIO_LOG_LEVEL | **Default**: `info` <br> The log level for this container. |

#### 3.  Deploy the DaemonSet

For the RBAC DaemonSet:

```shell
kubectl apply -f /path/to/logzio-daemonset-rbac.yaml
```

For the non-RBAC DaemonSet:

```shell
kubectl apply -f /path/to/logzio-daemonset.yaml
```

#### 4.  Check Logz.io for your logs

Give your logs some time to get from your system to ours,
and then open [Kibana](https://app.logz.io/#/dashboard/kibana).

If you still don't see your logs,
see [log shipping troubleshooting](https://docs.logz.io/user-guide/log-shipping/log-shipping-troubleshooting.html).

</div>
<!-- tab:end -->

## Disabling systemd input

To suppress Fluentd system messages, set the `FLUENTD_SYSTEMD_CONF` environment variable to `disable` in your Kubernetes environment.

### Disable prometheus input plugins

By default, latest images launch `prometheus` plugins to monitor fluentd.
You can disable prometheus input plugin by setting `disable` to `FLUENTD_PROMETHEUS_CONF` environment variable in your kubernetes configuration.

### Changelog
- v1.1.1
  - Upgrade fluentd base image to v.1.10.4
- v1.1.0
  - Update deprecated conifg
- v1.0.9
  - Update base image
  - Update libjemalloc package
- v1.0.8
  - Update deprecated APIs
- v1.0.7
  - Update dependencies
- v1.0.6
  - Use Kubernets secrets for Shipping Token and Listener URL.
  - Fix log level
