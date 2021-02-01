
# logzio-k8s

For Kubernetes, a DaemonSet ensures that some or all nodes run a copy of a pod.
This implementation is uses a Fluentd DaemonSet to collect Kubernetes logs.
Fluentd is flexible enough and has the proper plugins to distribute logs to different third parties such as Logz.io.

The logzio-k8s image comes pre-configured for Fluentd to gather all logs from the Kubernetes node environment and append the proper metadata to the logs.

You have two options for deployment:

* [Default configuration <span class="sm ital">(recommended)</span>](#default-config)
* [Custom configuration](#custom-config)

**Important notes:**
*   **K8S 1.19.3+**  - If you’re running on K8S 1.19.3+ or later, be sure to use the DaemonSet that supports a containerd at runtime. It can be downloaded and customized from[`logzio-daemonset-containerd.yaml`](https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset-containerd.yaml).
* **K8S 1.16 or earlier** - If you’re running K8S 1.16 or earlier, you may need to manually change the API version in your DaemonSet to `apiVersion: rbac.authorization.k8s.io/v1beta1`. The API versions of `ClusterRole` and `ClusterRoleBinding` are found in `logzio-daemonset-rbac.yaml` and `logzio-daemonset-containerd.yaml`. If you are running K8S 1.17 or later, the DaemonSet is set to use `apiVersion: rbac.authorization.k8s.io/v1` by default. No change is needed.
* The latest version pulls the image from `logzio/logzio-fluentd`. Previous versions pulled the image from `logzio/logzio-k8s`.

<div id="default-config">

## Deploy logzio-k8s with default configuration

For most environments, we recommend using the default configuration.
However, you can deploy a custom configuration if your environment needs it.

### To deploy logzio-k8s

#### 1. Create a monitoring namespace
Your DaemonSet will be deployed under the namespace `monitoring`.

```shell
kubectl create namespace monitoring
```

#### 2.  Store your Logz.io credentials

Save your Logz.io shipping credentials as a Kubernetes secret.

Replace `<<SHIPPING-TOKEN>>` with the [token](https://app.logz.io/#/dashboard/settings/general) of the account you want to ship to. <br>
Replace `<<LISTENER-HOST>>` with your region's listener host (for example, `listener.logz.io`).
For more information on finding your account's region,
see [Account region](https://docs.logz.io/user-guide/accounts/account-region.html).

```shell
kubectl create secret generic logzio-logs-secret \
--from-literal=logzio-log-shipping-token='<<SHIPPING-TOKEN>>' \
--from-literal=logzio-log-listener='https://<<LISTENER-HOST>>:8071' \
-n monitoring
```

#### 3.  Deploy the DaemonSet

For an RBAC cluster:

```shell
kubectl apply -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset-rbac.yaml -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/configmap.yaml
```

Or for a non-RBAC cluster:

```shell
kubectl apply -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset.yaml -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/configmap.yaml
```

For container runtime Containerd:
```shell
kubectl apply -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset-containerd.yaml -f https://raw.githubusercontent.com/logzio/logzio-k8s/master/configmap.yaml
```

#### 4.  Check Logz.io for your logs

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

#### 1. Create a monitoring namespace
This is the namespace that the Daemonset will be deployed under.

```shell
kubectl create namespace monitoring
```

#### 2.  Store your Logz.io credentials

Save your Logz.io shipping credentials as a Kubernetes secret.

Replace `<<SHIPPING-TOKEN>>` with the [token](https://app.logz.io/#/dashboard/settings/general) of the account you want to ship to. <br>
Replace `<<LISTENER-HOST>>` with your region's listener host (for example, `listener.logz.io`).
For more information on finding your account's region,
see [Account region](https://docs.logz.io/user-guide/accounts/account-region.html).

```shell
kubectl create secret generic logzio-logs-secret \
--from-literal=logzio-log-shipping-token='<<SHIPPING-TOKEN>>' \
--from-literal=logzio-log-listener='https://<<LISTENER-HOST>>:8071' \
-n monitoring
```

#### 3.  Configure Fluentd

There are 3 DaemonSet options:  [RBAC DaemonSet](https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset-rbac.yaml),  [non-RBAC DaemonSet](https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset.yaml),  [Containerd](https://raw.githubusercontent.com/logzio/logzio-k8s/master/logzio-daemonset-containerd.yaml). Download the relevant DaemonSet and open it in your text editor to edit it.

If you wish to make advanced changes in your Fluentd configuration, you can download and edit the  [configmap yaml file](https://raw.githubusercontent.com/logzio/logzio-k8s/master/configmap.yaml).

**Environment variables**
The following environment variables can be edited directly from the DaemonSet without editing the Configmap.

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
| INCLUDE_NAMESPACE | **Default**: `""`(All namespaces) <br> Use if you wish to send logs from specific k8s namespaces, space delimited. Should be in the following format: <br> `kubernetes.var.log.containers.**_<<NAMESPACE-TO-INCLUDE>>_** kubernetes.var.log.containers.**_<<ANOTHER-NAMESPACE>>_**`. |
| KUBERNETES_VERIFY_SSL | **Default**: `true` <br> Enable to validate SSL certificates. |
| FLUENT_FILTER_KUBERNETES_URL | **Default**: `nil` (doesn't appear in the pre-made Daemonset) <br> URL to the API server. Set this to retrieve further kubernetes metadata for logs from kubernetes API server. If not specified, environment variables `KUBERNETES_SERVICE_HOST` and `KUBERNETES_SERVICE_PORT` will be used if both are present which is typically true when running fluentd in a pod. <br> **Please note** that this parameter does NOT appear in the pre-made environment variable list in the Daemonset. If you wish to use & set this variable, you'll have to add it to the Daemonset's environment variables. |
| AUDIT_LOG_FORMAT | **Default**: `audit` <br> The format of your audit logs. If your audit logs are in json format, set to `audit-json`.  |

If you wish to make any further changes in Fluentd's configuration, download the [configmap file](https://raw.githubusercontent.com/logzio/logzio-k8s/master/configmap.yaml), open the file in your text editor and make the changes that you need.


#### 4.  Deploy the DaemonSet

For the RBAC DaemonSet:

```shell
kubectl apply -f /path/to/logzio-daemonset-rbac.yaml -f /path/to/configmap.yaml
```

For the non-RBAC DaemonSet:

```shell
kubectl apply -f /path/to/logzio-daemonset.yaml -f /path/to/configmap.yaml
```

For container runtime Containerd:
```shell
kubectl apply -f /path/to/logzio-daemonset-containerd.yaml -f /path/to/configmap.yaml
```

#### 5.  Check Logz.io for your logs

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
**logzio/logzio-fluentd**:
- v1.0.0:
  - Fluentd configuration will be pulled from `configmap.yaml`.
  - Allow changing audit logs format via env var `AUDIT_LOG_FORMAT`.
  - Update API version for RBAC Daemonsets.
**logzio/logzio-k8s:**
This docker image is deprecated. Please use the logzio/logzio-fluentd image instead.
- v1.1.6
  - Allow changing of SSL configurations.
- v1.1.5
  - Bumped Fluentd version to v.1.11.5 (thanks @jeroenzeegers).
  - Fixed docker image: changed workdir & removed wrong gem path (thanks @pete911).
  - Configured Fluentd to exclude its own logs.
  - Allow sending logs from specific k8s namespaces.
- v1.1.4
  - Add `fluent-plugin-kubernetes_metadata_filter`.
- v1.1.3
  - Support containerd.
- v1.1.2
  - Fix token display issue.
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
