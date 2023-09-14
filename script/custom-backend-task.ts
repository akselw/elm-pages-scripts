import { exec } from 'child_process'

export async function openChrome(url) {
    console.log({ url });
    exec(`open -a "Google Chrome Canary" ${url}`);
}
