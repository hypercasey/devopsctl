"use strict";
// Enables the ability to launch a remote DevOps stack,
// attach the VNICs, assign the Public IP's to the VNIC's,
// or run terminate and destroy operations.
import { env } from "process";
import { stackOperations as so } from "./stack-operations";
let killDevOpsServer = `${env.KILL_DEVOPS_SERVER}` || "false";

(async () => {
  try {
    // For troubleshooting the instance termination process.
    // killDevOpsServer = "true";
    if (killDevOpsServer === "true") {
      let terminateDevOpsInstance = {
        dead: await so.destroyDevOpsServer(),
      };

      return (terminateDevOpsInstance.dead ? `${terminateDevOpsInstance.dead}` : () => {
        so.croak({ warning: `${terminateDevOpsInstance.dead}`, stage: "destroyDevOpsServer" });
      });
      // For situations when you want to terminate
      // the instance but retain the boot volume.
      // Careful enabling this. You will need to
      // keep an eye on Block Storage to ensure
      // excessive volumes are not created if this
      // is run instead of the "DESTROY" operations.
      // This is intended more for stacks that
      // target an UHP persistent volume boot source
      // that do not need to generate a new boot
      // volume each time whenever run.
      // if (killDevOpsServer === "true") {
      //   let killDevOpsInstance = {
      //     id: await so.getInstanceId(),
      //     dead: "",
      //   };

      //   if (killDevOpsInstance.id) {
      //     killDevOpsInstance = {
      //       id: killDevOpsInstance.id,
      //       dead: await so.terminateDevOpsServer({ ocid: `${killDevOpsInstance.id}` }),
      //     };

      //     return (killDevOpsInstance.dead ? `${killDevOpsInstance.id}` : () => {
      //       so.croak({ warning: `${killDevOpsInstance.dead}`, stage: "terminateDevOpsServer" });
      //     });
      //   }
      // }
    } else {
      let runDevOpsStack = {
        status: await so.createDevopsServer(),
        id: "",
        ip: "",
        vnic: "",
      };
      // Give the apply operation time to complete.
      await so.sleep({ interval: 75000 });
      runDevOpsStack = {
        status: runDevOpsStack.status,
        id: await so.getInstanceId(),
        ip: "",
        vnic: "",
      };
      await so.sleep({ interval: 15000 });
      if (0 < runDevOpsStack.id.length && "" != `${so.assignPublicIp}`)
        runDevOpsStack = {
          status: runDevOpsStack.status,
          id: runDevOpsStack.id,
          ip: await so.attachPublicIp(),
          vnic: "",
        };
      await so.sleep({ interval: 15000 });
      // For preconfigured public ip.
      if (runDevOpsStack.ip === "ASSIGNED")
        runDevOpsStack = {
          status: runDevOpsStack.status,
          id: runDevOpsStack.id,
          ip: runDevOpsStack.ip,
          vnic: await so.attachVnic({ ocid: `${runDevOpsStack.id}` }),
        };
      // For auto assigned public ip.
      if ("" === `${so.assignPublicIp}`)
        runDevOpsStack = {
          status: runDevOpsStack.status,
          id: runDevOpsStack.id,
          ip: "AUTO",
          vnic: await so.attachVnic({ ocid: `${runDevOpsStack.id}` }),
        };

      return (runDevOpsStack.vnic === "ATTACHED" ? `{ status: "SUCCEEDED", message: { job: "${runDevOpsStack.status}", id: "${runDevOpsStack.id}", ip: "${runDevOpsStack.ip}", vnic: "${runDevOpsStack.vnic}" } }` && process.exit(0) : `{ status: "FAILED", message: { job: "${runDevOpsStack.status}", id: "${runDevOpsStack.id}", ip: "${runDevOpsStack.ip}", vnic: "${runDevOpsStack.vnic}" } }` && process.exit(1));
    }
  } catch (error) {
    return so.choke({ error: `${error}`, stage: "runDevOpsStack" });
  }
})();
