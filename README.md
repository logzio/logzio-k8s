This is a Logz.io fluend solution for kubernetes.

##Fluentd DaemonSet
For Kubernetes, a DaemonSet ensures that all (or some) nodes run a copy of a pod. In order to solve log collection we are going to implement a Fluentd DaemonSet.

Fluentd is flexible enough and have the proper plugins to distribute logs to different third party like Logz.io.

##DaemonSet Content
This repository contains the several configurations that allow to deploy Fluentd as a DaemonSet, the Docker container image distributed on this repository also comes pre-configured so Fluentd can gather all logs from the Kubernetes node environment and also it appends the proper metadata to the logs.

##Logging to Logz.io
###Daemonset configuration
The daemonset yaml file have two relevant environment variables that are used by Fluentd when the container starts:

| Environment Variable | Description |
|----------------------|-------------|
|   LOGZIO_TOKEN       | This is your Logz.io account token |
|   LOGZIO_URL         | This is your Logz.io listener url |

###Logz.io endpoint configuration
Here you can configure Logz.io fluentd endpoint shipping behavior

| Variable | Description | Default |
|------------------|----------------------------|---------|
| endpoint_url | The url to Logz.io input | #{ENV['LOGZIO_URL']}?token=#{ENV['LOGZIO_TOKEN']}
| output_include_time | Should the appender add a timestamp to your logs on their process time. (recommended).| true
| buffer_type |  This option specifies which plugin to use as the backend.| file
| buffer_path | The path of the buffer | /var/log/fluentd-buffers/stackdriver.buffer
| buffer_queue_full_action | Controls the behaviour when the queue becomes full.| block
| buffer_chunk_limit | The maximum size of a chunk allowed | 2M
| buffer_queue_limit | The maximum length of the output queue | 6
| flush_interval | The interval in seconds to wait before invoking the next buffer flush | 5s
| max_retry_wait | The maximum interval seconds to wait between retries | 30s
| num_threads | The number of threads to flush the buffer. | 2

### Running on OpenShift

This daemonset setting mounts `/var/log` as service account `fluentd` so you need to run containers as privileged container.
Here is command example:


