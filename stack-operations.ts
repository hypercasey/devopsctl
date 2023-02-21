"use strict";
// Enables the ability to launch a remote DevOps stack,
// attach the VNICs, assign the Public IP's to the VNIC's,
// or run terminate and destroy operations.
import { common } from "oci-sdk";
import { core } from "oci-sdk";
import { resourcemanager as rm } from "oci-sdk";
import { workrequests as wr } from "oci-sdk";
import { devOpsConfig as dev } from "./devops-config";

const provider: common.ConfigFileAuthenticationDetailsProvider =
  new common.ConfigFileAuthenticationDetailsProvider();
const computeClient = new core.ComputeClient({
  authenticationDetailsProvider: provider,
});
const networkClient = new core.VirtualNetworkClient({
  authenticationDetailsProvider: provider,
});
const jobClient = new rm.ResourceManagerClient({
  authenticationDetailsProvider: provider,
});
const workRequestClient = new wr.WorkRequestClient({
  authenticationDetailsProvider: provider,
});
const maxTimeInSeconds = 60 * 60;
const maxDelayInSeconds = 30;
const waiterConfiguration: common.WaiterConfiguration = {
  terminationStrategy: new common.MaxTimeTerminationStrategy(maxTimeInSeconds),
  delayStrategy: new common.ExponentialBackoffDelayStrategy(maxDelayInSeconds),
};
const computeWaiter = computeClient.createWaiters(
  workRequestClient,
  waiterConfiguration
);
const primaryPrivateIp = `${dev.ociPrivateIp[0]}`;
const secondaryPrivateIp = `${dev.ociPrivateIp[1]}`;
const tertiaryPrivateIp = `${dev.ociPrivateIp[2]}`;
const quaternaryPrivateIp = `${dev.ociPrivateIp[3]}`;
const primarySubnetId = `${dev.ociSubnetId[0]}`;
const secondarySubnetId = `${dev.ociSubnetId[1]}`;
const tertiarySubnetId = `${dev.ociSubnetId[2]}`;
const quaternarySubnetId = `${dev.ociSubnetId[3]}`;

export const stackOperations = {

  sleep: async function sleep({ interval }: { interval: number }): Promise<any> {
    return new Promise((resolve) => setTimeout(resolve, interval));
  },

  croak: function croak({ warning, stage }: { warning: string, stage: string }): string {
    console.warn(`{ status: "WARNING", message: { condition: "${warning}", stage: "${stage}" } }`);
    return `{ status: "WARNING", message: { condition: "${warning}", stage: "${stage}" } }`;
  },

  choke: function choke({ error, stage }: { error: string, stage: string }): string {
    console.error(`{ status: "FAILED", message: { error: "${error}", stage: "${stage}" } }`);
    return `{ status: "FAILED", message: { error: "${error}", stage: "${stage}" } }`;
  },

  createDevopsServer: async function createDevopsServer(): Promise<string> {
    // Runs "APPLY" on the DevOps stack and returns the status.
    // In this case the stack creates a "preemptible" capacity
    // instance from a Custom Image source that has already been
    // configured to pull everything it needs from a private
    // container registry for a stable, clean - slated build
    // environment.
    try {
      const createJobDetails = {
        stackId: `${dev.ociStackId}`,
        displayName: `${dev.ociStackName}`,
        operation: rm.models.Job.Operation.Apply,
        jobOperationDetails: {
          operation: "APPLY",
          executionPlanStrategy:
            rm.models.ApplyJobOperationDetails.ExecutionPlanStrategy.AutoApproved,
        },
      };
      const createJobRequest: rm.requests.CreateJobRequest = {
        createJobDetails: createJobDetails,
      };
      const createJobResponse = await jobClient.createJob(createJobRequest);
      const jobStatus = `${createJobResponse.job.lifecycleState}`;

      return (jobStatus
        ? `${jobStatus}`
        : this.choke({ error: `${jobStatus}`, stage: "createJobRequest" }));
    } catch (error) {
      return this.choke({ error: `${error}`, stage: "createJobRequest" });
    }
  },

  getInstanceId: async function getInstanceId(): Promise<string> {
    try {
      const listInstancesRequest: core.requests.ListInstancesRequest = {
        compartmentId: `${dev.compartmentId}`,
        availabilityDomain: `${dev.availabilityDomain}`,
        displayName: `${dev.displayName}`,
        lifecycleState: core.models.Instance.LifecycleState.Running,
      };
      const listInstancesResponse = await computeClient.listInstances(
        listInstancesRequest
      );
      const instanceId = `${listInstancesResponse.items[0].id}`;

      return (instanceId
        ? `${instanceId}`
        : this.choke({ error: `${instanceId}`, stage: "listInstancesRequest" }));
    } catch (error) {
      return this.choke({ error: `${error}`, stage: "listInstancesRequest" });
    }
  },

  assignPublicIp: `${dev.ociPublicIpId}`,

  attachPublicIp: async function attachPublicIp(): Promise<string> {
    try {
      const listPrivateIpsRequest: core.requests.ListPrivateIpsRequest = {
        subnetId: `${primarySubnetId}`,
        ipAddress: `${primaryPrivateIp}`,
      };
      const listPrivateIpsResponse = await networkClient.listPrivateIps(
        listPrivateIpsRequest
      );
      const updatePublicIpDetails = {
        displayName: `${dev.ociPublicIpDisplayName}`,
        freeformTags: {
          ociPublicServiceName: `${dev.ociPublicServiceName}`,
        },
        privateIpId: `${listPrivateIpsResponse.items[0].id}`,
      };
      const updatePublicIpRequest: core.requests.UpdatePublicIpRequest = {
        publicIpId: `${dev.ociPublicIpId}`,
        updatePublicIpDetails: updatePublicIpDetails,
      };
      const updatePublicIpResponse = await networkClient.updatePublicIp(
        updatePublicIpRequest
      );
      const publicIpStatus = `${updatePublicIpResponse.publicIp.lifecycleState}`;

      return (publicIpStatus
        ? `${publicIpStatus}`
        : this.croak({ warning: `${publicIpStatus}`, stage: "updatePublicIpRequest" }));
    } catch (error) {
      return this.croak({ warning: `${error}`, stage: "updatePublicIpRequest" });
    }
  },

  attachVnic: async function attachVnic({ ocid }: { ocid: string }): Promise<string> {
    try {
      // The Primary VNIC is allocated by the stack
      // itself so we only need to worry about the
      // other ones which varies depending on the
      // shape of the instance.

      // The Oracle Cloud Agent service should be enabled
      // on the instance before running the stack to
      // automatically configure the VNIC's once they attach.
      // The Management Agent and OS Management Service Agent
      // are also required for this to work. They will need
      // to be enabled through the cloud portal during
      // instance creation and in the stack's terraform file.

      // Step One:
      // is_management_disabled = "false"
      // plugins_config {
      //   desired_state = "ENABLED"
      //   name = "OS Management Service Agent"
      // }
      // plugins_config {
      //   desired_state = "ENABLED"
      //   name = "Management Agent"
      // }

      // Step Two:
      // systemctl enable --now ocid.service
      // systemctl enable --now oracle-cloud-agent.service
      // systemctl enable --now oracle-cloud-agent-updater.service
      // Step Three:
      // systemctl reboot
      // Step Four:
      // ip addr (verify if VNIC was configured).

      // Note that if making a Custom Image it's
      // recommended to manually shut down the
      // instance first with systemctl poweroff
      // to prevent systemd from desynchronizing
      // with the Cloud Agent scripts.

      const attachVnic2Details = {
        createVnicDetails: {
          assignPublicIp: true,
          assignPrivateDnsRecord: true,
          displayName: `${dev.secondaryVnicDisplayName}`,
          hostnameLabel: `${dev.secondaryVnicHostnameLabel}`,
          privateIp: `${secondaryPrivateIp}`,
          skipSourceDestCheck: false,
          subnetId: `${secondarySubnetId}`,
        },
        displayName: `${dev.secondaryVnicDisplayName}`,
        instanceId: `${ocid}`,
      };
      const attachVnic2Request: core.requests.AttachVnicRequest = {
        attachVnicDetails: attachVnic2Details,
      };
      let attachVnic2Response = await computeClient.attachVnic(
        attachVnic2Request
      );
      let vnic2Status = `${attachVnic2Response.vnicAttachment.lifecycleState}`;

      if (tertiaryPrivateIp) {
        const attachVnic3Details = {
          createVnicDetails: {
            assignPublicIp: true,
            assignPrivateDnsRecord: true,
            displayName: `${dev.tertiaryVnicDisplayName}`,
            hostnameLabel: `${dev.tertiaryVnicHostnameLabel}`,
            privateIp: `${tertiaryPrivateIp}`,
            skipSourceDestCheck: false,
            subnetId: `${tertiarySubnetId}`,
          },
          displayName: `${dev.tertiaryVnicDisplayName}`,
          instanceId: `${ocid}`,
        };
        const attachVnic3Request: core.requests.AttachVnicRequest = {
          attachVnicDetails: attachVnic3Details,
        };

        // Give the previous instance modification
        // some time to finish before attaching
        // the next VNIC otherwise it will fail with
        // "instance is currently being modified, try
        // again later".
        await this.sleep({ interval: 20000 });
        let attachVnic3Response = await computeClient.attachVnic(
          attachVnic3Request
        );
        let vnic3Status = `${attachVnic3Response.vnicAttachment.lifecycleState}`;

        if (!quaternaryPrivateIp) {
          return (vnic2Status === "ATTACHED" || vnic2Status === "ATTACHING" && vnic3Status === "ATTACHED" || vnic3Status === "ATTACHING" ? "ATTACHED" : this.croak({
            warning: `[ "${vnic2Status}", "${vnic3Status}" ],`, stage: "attachVnicRequest"
          }));
        } else {
          // Oracle seems to have some kind of obscure
          // limitation on the number of VNIC's that can
          // be attached to an instance. When attempting
          // to attach more than 3 VNIC's, it quietly
          // removes them contrary to what is described
          // in the service limits about OCPU's and VNIC's.
          const attachVnic4Details = {
            createVnicDetails: {
              assignPublicIp: true,
              assignPrivateDnsRecord: true,
              displayName: `${dev.quaternaryVnicDisplayName}`,
              hostnameLabel: `${dev.quaternaryVnicHostnameLabel}`,
              privateIp: `${quaternaryPrivateIp}`,
              skipSourceDestCheck: false,
              subnetId: `${quaternarySubnetId}`,
            },
            displayName: `${dev.quaternaryVnicDisplayName}`,
            instanceId: `${ocid}`,
          };
          const attachVnic4Request: core.requests.AttachVnicRequest = {
            attachVnicDetails: attachVnic4Details,
          };
          await this.sleep({ interval: 20000 });
          let attachVnic4Response = await computeClient.attachVnic(
            attachVnic4Request
          );
          let vnic4Status = `${attachVnic4Response.vnicAttachment.lifecycleState}`;

          return (vnic2Status === "ATTACHED" || vnic2Status === "ATTACHING" && vnic3Status === "ATTACHED" || vnic3Status === "ATTACHING" && vnic4Status === "ATTACHED" || vnic4Status === "ATTACHING" ? "ATTACHED" : this.croak({
            warning: `[ "${vnic2Status}", "${vnic3Status}", "${vnic4Status}" ],`, stage: "attachVnicRequest"
          }));
        }
      }

      return (vnic2Status === "ATTACHED" || vnic2Status === "ATTACHING" ? "ATTACHED" : this.croak({
        warning: `[ "${vnic2Status}" ],`, stage: "attachVnicRequest"
      }));

    } catch (error) {
      return this.croak({ warning: `${error}`, stage: "attachVnicRequest" });
    }
  },

  terminateDevOpsServer: async function terminateDevOpsServer({
    ocid,
  }: {
    ocid: string;
  }): Promise<string> {
    // For situations where you want to terminate
    // the instance but retain the boot volume.
    // Careful enabling this. You will need to
    // keep an eye on Block Storage to ensure
    // excessive volumes are not created if this
    // is run instead of the "DESTROY" operations.
    // This is intended more for stacks that
    // target an UHP persistent volume boot source
    // that do not need to generate a new boot
    // volume each time whenever run.
    try {
      const terminateInstanceRequest: core.requests.TerminateInstanceRequest = {
        instanceId: `${ocid}`,
        preserveBootVolume: true,
      };

      await computeClient.terminateInstance(terminateInstanceRequest);

      const getInstanceRequest: core.requests.GetInstanceRequest = {
        instanceId: `${ocid}`,
      };

      await computeWaiter.forInstance(
        getInstanceRequest,
        core.models.Instance.LifecycleState.Terminated
      );

      const getInstanceResponse = await computeClient.getInstance(
        getInstanceRequest
      );
      const instanceStatus = `${getInstanceResponse.instance.lifecycleState}`;

      return (instanceStatus
        ? `${instanceStatus}`
        : this.croak({ warning: `${instanceStatus}`, stage: "terminateInstanceRequest" }));
    } catch (error) {
      return this.croak({ warning: `${error}`, stage: "terminateInstanceRequest" });
    }
  },

  destroyDevOpsServer: async function destroyDevOpsServer(): Promise<string> {
    // Runs "DESTROY" on the DevOps stack and returns the status.
    try {
      const destroyJobDetails = {
        stackId: `${dev.ociStackId}`,
        displayName: `${dev.ociStackName}`,
        operation: rm.models.Job.Operation.Destroy,
        jobOperationDetails: {
          operation: "DESTROY",
          executionPlanStrategy:
            rm.models.DestroyJobOperationDetails.ExecutionPlanStrategy.AutoApproved,
        },
      };
      const destroyJobRequest: rm.requests.CreateJobRequest = {
        createJobDetails: destroyJobDetails,
      };
      const createJobResponse = await jobClient.createJob(destroyJobRequest);
      const jobStatus = `${createJobResponse.job.lifecycleState}`;

      return (jobStatus
        ? `${jobStatus}`
        : this.choke({ error: `${jobStatus}`, stage: "destroyJobRequest" }));
    } catch (error) {
      return this.choke({ error: `${error}`, stage: "destroyJobRequest" });
    }
  }
}
