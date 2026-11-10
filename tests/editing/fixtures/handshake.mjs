import { Worker, isMainThread, parentPort, workerData } from 'node:worker_threads';
import { fileURLToPath } from 'node:url';

// READY -> GO -> WRITE -> COMMIT is an explicit concurrent gate. No timer or
// sleep participates in establishing order. Real product attachment is pending.
if (!isMainThread) {
  const gate = new Int32Array(workerData.gate);
  if (workerData.role === 'writer') {
    parentPort.postMessage('READY');
    Atomics.wait(gate, 0, 0);
    Atomics.store(gate, 1, 1); // stand-in shared source version for tool selftest only
    parentPort.postMessage('WRITE');
  } else {
    parentPort.postMessage('READY');
    Atomics.wait(gate, 2, 0);
    parentPort.postMessage(Atomics.load(gate, 1) === 1 ? 'COMMIT_AFTER_WRITE' : 'ORDER_ERROR');
  }
} else if (process.argv.includes('--selftest')) {
  const gate = new Int32Array(new SharedArrayBuffer(3 * Int32Array.BYTES_PER_ELEMENT));
  const actor = role => {
    const worker = new Worker(fileURLToPath(import.meta.url), { workerData: { role, gate: gate.buffer } });
    const messages = [];
    const done = new Promise((resolve, reject) => {
      worker.on('message', value => { messages.push(value); if (value !== 'READY') resolve(value); });
      worker.on('error', reject);
      worker.on('exit', code => { if (code !== 0) reject(new Error(`${role} exit ${code}`)); });
    });
    return { messages, done };
  };
  const writer = actor('writer');
  const ui = actor('ui');
  while (writer.messages[0] !== 'READY' || ui.messages[0] !== 'READY') {
    await new Promise(resolve => setImmediate(resolve));
  }
  Atomics.store(gate, 0, 1);
  Atomics.notify(gate, 0);
  if (await writer.done !== 'WRITE') throw new Error('writer handshake');
  Atomics.store(gate, 2, 1);
  Atomics.notify(gate, 2);
  if (await ui.done !== 'COMMIT_AFTER_WRITE') throw new Error('UI handshake');
  console.log('PASS real worker handshake READY/GO/WRITE/COMMIT');
} else {
  throw new Error('use --selftest; product race adapter is not yet available');
}
