import { chromium } from 'playwright';
import fs from 'fs';
const src = fs.readFileSync(new URL('file://' + process.cwd() + '/onboarding.js')).toString();
const b = await chromium.launch();
const p = await b.newPage();
await p.route('**/ob-test', r => r.fulfill({ contentType: 'text/html', body: '<body style="--bg:#111;--text:#eee;--accent:#3B82F6"></body>' }));
await p.goto('http://ob.test/ob-test');
await p.addScriptTag({ content: src });
const shown = await p.evaluate(() => Onboarding.start({
  key:'t', signedIn:false, finishLabel:'Go',
  slides:[{title:'One',body:'first'},{title:'Two',body:'second'}]
}));
console.assert(shown === true, 'should show');
console.assert(await p.textContent('.ob-h') === 'One');
console.assert((await p.$$('.ob-dot')).length === 2);
console.assert(await p.textContent('.ob-next') === 'Next');
await p.click('.ob-next');
console.assert(await p.textContent('.ob-h') === 'Two');
console.assert(await p.textContent('.ob-next') === 'Go');
await p.screenshot({ path: '/tmp/claude-501/-Users-joshua/f29eb9b0-30f8-4c0c-b8d6-50a09e28d9fa/scratchpad/ob.png' });
await p.click('.ob-next');
console.assert((await p.$$('.ob-veil')).length === 0, 'closed');
console.assert(await p.evaluate(() => localStorage.getItem('t_onboarded')) === '1');
const again = await p.evaluate(() => Onboarding.start({key:'t',signedIn:false,slides:[{title:'x',body:'y'}]}));
console.assert(again === false, 'second run suppressed');
const authed = await p.evaluate(() => Onboarding.start({key:'z',signedIn:true,slides:[{title:'x',body:'y'}]}));
console.assert(authed === false, 'signed-in suppressed');
await b.close();
console.log('ALL PASS');
