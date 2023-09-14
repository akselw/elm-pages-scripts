// script/custom-backend-task.ts
import { exec } from "child_process";
async function test2(url) {
  console.log({ url });
  exec(`open -a "Google Chrome Canary" ${url}`);
}
export {
  test2
};
