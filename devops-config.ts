"use strict";
// This is where you will define all necessary
// configuration details for the DevOps stack.

export const devOpsConfig = {
  compartmentId:
    "ocid1.compartment.oc1..aaaaaaaahtwo62wwjxafjfqspdcjwdbhbg35rfudn5l6o5stbbjobvonhxrq",
  availabilityDomain: "NeVq:US-ASHBURN-AD-1",
  displayName: "devops.us.hyperspire.net",
  // It's recommended to run destroy (systemctl
  // stop devopsctl.service) on any stack
  // currently in operation before switching
  // to a different stack. Otherwise, it will
  // not be able to launch the new stack util
  // the network resources from the old stack
  // are released by running destroy manually.
  // Stack Sourced from Custom Image:
  ociStackId: "ocid1.ormstack.oc1.iad.aaaaaaaa7n73pefnfw7c6oljce6hgnkew4l4l6wxdwrkrlnt5zd5rjavutja",
  // Stack Sourced from Oracle Supplied Image:
  // ociStackId: "ocid1.ormstack.oc1.iad.aaaaaaaaxrf3ohda4w2enjkfxzru6ufvqgqlon3vtwcnovbj3wkjkv4xnw3a",
  // Stack Sourced from Persistent Volume:
  // ociStackId: "",
  ociStackName: "devops.us.hyperspire.net",
  ociPublicServiceName: "devops",
  ociPublicIpDisplayName: "devops.us.hyperspire.net",
  ociPublicIpId:
    "ocid1.publicip.oc1.iad.amaaaaaai24d7pyan3yfa56st7onyx5qh5n4hxlakawbp3zqctewhcpjvy4a",
  ociSubnetId: [
    "ocid1.subnet.oc1.iad.aaaaaaaatranxwovresn77vuhvg3wemw2wsdib5hztitxfvu6cnwwspgp7ja",
    "ocid1.subnet.oc1.iad.aaaaaaaatranxwovresn77vuhvg3wemw2wsdib5hztitxfvu6cnwwspgp7ja",
    "",
    ""],
  ociPrivateIp: ["10.10.10.10", "10.10.10.100", "", ""],
  primaryVnicHostnameLabel: "devops",
  primaryVnicDisplayName: "devops.us.hyperspire.net",
  secondaryVnicHostnameLabel: "devops-100",
  secondaryVnicDisplayName: "devops-100.priv.us.hyperspire.net",
  tertiaryVnicHostnameLabel: "",
  tertiaryVnicDisplayName: "",
  quaternaryVnicHostnameLabel: "",
  quaternaryVnicDisplayName: "",
};
