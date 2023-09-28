import { exec } from 'child_process'

export async function openChrome(url) {
    await exec(`open -a "Google Chrome Canary" ${url}`);
    await new Promise(r => setTimeout(r, 150));
}
