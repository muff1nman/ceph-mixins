{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'osd-alert.rules',
        rules: [
          {
            alert: 'CephOSDCriticallyFull',
            expr: |||
              (ceph_osd_metadata * on (ceph_daemon) group_left() (ceph_osd_stat_bytes_used / ceph_osd_stat_bytes)) >= 0.85
            ||| % $._config,
            'for': $._config.osdUtilizationAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Back-end storage device is critically full.',
              description: 'Utilization of back-end storage device {{ $labels.ceph_daemon }} has crossed 85% on host {{ $labels.hostname }}. Immediately free up some space or expand the storage cluster or contact support.',
              storage_type: $._config.storageType,
              severity_level: 'error',
            },
          },
          {
            alert: 'CephOSDNearFull',
            expr: |||
              (ceph_osd_metadata * on (ceph_daemon) group_left() (ceph_osd_stat_bytes_used / ceph_osd_stat_bytes)) >= 0.75
            ||| % $._config,
            'for': $._config.osdUtilizationAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'Back-end storage device is nearing full.',
              description: 'Utilization of back-end storage device {{ $labels.ceph_daemon }} has crossed 75% on host {{ $labels.hostname }}. Free up some space or expand the storage cluster or contact support.',
              storage_type: $._config.storageType,
              severity_level: 'warning',
            },
          },
          {
            alert: 'CephOSDDiskNotResponding',
            expr: |||
              label_replace((ceph_osd_in == 1 and ceph_osd_up == 0),"disk","$1","ceph_daemon","osd.(.*)") + on(ceph_daemon) group_left(host, device) label_replace(ceph_disk_occupation,"host","$1","exported_instance","(.*)")
            ||| % $._config,
            'for': $._config.osdDiskAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Disk not responding',
              description: 'Disk device {{ $labels.device }} not responding, on host {{ $labels.host }}.',
              storage_type: $._config.storageType,
              severity_level: 'error',
            },
          },
          {
            alert: 'CephOSDDiskUnavailable',
            expr: |||
              label_replace((ceph_osd_in == 0 and ceph_osd_up == 0),"disk","$1","ceph_daemon","osd.(.*)") + on(ceph_daemon) group_left(host, device) label_replace(ceph_disk_occupation,"host","$1","exported_instance","(.*)")
            ||| % $._config,
            'for': $._config.osdDiskAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Disk not accessible',
              description: 'Disk device {{ $labels.device }} not accessible on host {{ $labels.host }}.',
              storage_type: $._config.storageType,
              severity_level: 'error',
            },
          },
          {
            alert: 'CephDataRecoveryTakingTooLong',
            expr: |||
              ceph_pg_undersized > 0
            ||| % $._config,
            'for': $._config.osdDataRecoveryAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'Data recovery is slow',
              description: 'Data recovery has been active for too long. Contact Support.',
              storage_type: $._config.storageType,
              severity_level: 'warning',
            },
          },
          {
            alert: 'CephPGRepairTakingTooLong',
            expr: |||
              ceph_pg_inconsistent > 0
            ||| % $._config,
            'for': $._config.PGRepairAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'Self heal problems detected',
              description: 'Self heal operations taking too long. Contact Support.',
              storage_type: $._config.storageType,
              severity_level: 'warning',
            },
          },
        ],
      },
    ],
  },
}
