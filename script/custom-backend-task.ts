import { exec } from 'child_process'

export async function openChrome(url) {
    exec(`open -a "Google Chrome Canary" ${url}`);
}
