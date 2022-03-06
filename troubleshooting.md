# Troubleshooting

This document contains some guides for handling errors that you may encounter when trying to run this solution.

### Add extra mounts:

If you see this error when running Fluentd:

```shell
/file/path.log unreadable. it is excluded and would be examined next time
```

It might be because you need to add more volume and volume mount to your Daemonset. Follow these steps:

#### Step 1 - Check on which node your pod is running

You'll need to find out on which node your Fluentd pod with the errors is running on. To do so use this command:

```shell
kubectl -n <<NAMESPACE>> get pod <<FLUENTD-POD-NAME>> -owide
```

#### Step 2 - Connect to the node

You'll need to connect to the node you found in the previous step (ssh, etc...).

#### Step 3 - Find the log's path:

1. Run the following command, to go to the logs directory:

```shell
cd /var/log/containers
```

2. Run the following command to display the log files symlinks:

```shell
ls -ltr
```

This command should present you a list of your log files and their symlinks. It should look something like this:

```shell
some-log-file.log -> /var/log/pods/file_name.log
```

3. Choose one of those logs, copy the symlink, and run the following command:

```shell
ls -ltr /var/log/pods/file_name.log
```

Again, this command will output the file and its symlink. For example:

```shell
/var/log/pods/file_name.log -> /some/other/path/file.log
```

This directory (`/some/other/path`) is the directory where your log files mounted at the host. You'll need to add that path to your Daemonset.

#### Step 4 - Add the mount path to your daemonset

1. Open your daemonset in your preffered text editor.

2. In the `volumeMounts` section, add the following:

```yaml
- name: logextramount
  mountPath: <<MOUNT-PATH>>
  readOnly: true
```

Replace `<<MOUNT-PATH>>` with the directory path you've found in step 3.

3. In the `volumes` section, add the following:

```yaml
- name: logextramount
  hostPath:
  	path: <<MOUNT-PATH>>
```

Replace `<<MOUNT-PATH>>` with the directory path you've found in step 3.

Save your changes.

#### Step 5 - Deploy your new Daemonset.

Remove your previous Daemonset from the cluster, and apply your new one (note that applying the new Daemonset without removing the old one won't apply the changes).

### Step 6 - Check your Fluentd pods to ensure that the error is gone