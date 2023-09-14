
// const exec = require('child_process').exec;

import { exec } from 'child_process'

export async function test2(url) {
    console.log({ url });
    exec(`open -a "Google Chrome Canary" ${url}`);
}
