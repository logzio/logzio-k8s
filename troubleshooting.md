# Troubleshooting

This document contains some guidelines for handling errors that you may encounter when trying to run this solution.

## Problem: /file/path.log unreadable

The following error appears when running Fluentd:

```shell
/file/path.log unreadable. it is excluded and would be examined next time
```

### Possible cause

You may need to add more volume and volume mount to your Daemonset.

### Suggested remedy

#### Step 1 - Check on which node your pod is running

Find out on which node your Fluentd pod with the errors is running. To do so, use this command:

```shell
kubectl -n <<NAMESPACE>> get pod <<FLUENTD-POD-NAME>> -owide
```

#### Step 2 - Connect to the node

Connect to the node you found in the previous step (ssh, etc...).

#### Step 3 - Find the log's path:

1. Run the following command, to go to the logs directory:

```shell
cd /var/log/containers
```

2. Run the following command to display the log files symlinks:

```shell
ls -ltr
```

This command should present you a list of your log files and their symlinks, for example:

```shell
some-log-file.log -> /var/log/pods/file_name.log
```

3. Choose one of those logs, copy the symlink, and run the following command:

```shell
ls -ltr /var/log/pods/file_name.log
```

Again, this command will output the file and its symlink, or example:

```shell
/var/log/pods/file_name.log -> /some/other/path/file.log
```

This directory (`/some/other/path`) is the directory where your log files are mounted at the host. You'll need to add that path to your Daemonset.

#### Step 4 - Add the mount path to your Daemonset

1. Open your Daemonset in your preffered text editor.

2. In the `volumeMounts` section, add the following:

```yaml
- name: logextramount
  mountPath: <<MOUNT-PATH>>
  readOnly: true
```

Replace `<<MOUNT-PATH>>` with the directory path you found in step 3.

3. In the `volumes` section, add the following:

```yaml
- name: logextramount
  hostPath:
  	path: <<MOUNT-PATH>>
```

Replace `<<MOUNT-PATH>>` with the directory path you found in step 3.

4. Save the changes.

#### Step 5 - Deploy your new Daemonset.

Remove your previous Daemonset from the cluster, and apply the new one.

NOTE: Applying the new Daemonset without removing the old one will not apply the changes.

#### Step 6 - Check your Fluentd pods to ensure that the error is gone

```shell
kubectl -n <<NAMESPACE>> logs <<POD-NAME>>
```
