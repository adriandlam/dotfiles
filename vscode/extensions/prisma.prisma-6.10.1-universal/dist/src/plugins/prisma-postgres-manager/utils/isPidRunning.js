"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isPidRunning = isPidRunning;
function isPidRunning(pid) {
    try {
        process.kill(pid, 0);
        return true;
    }
    catch (_a) { }
    return false;
}
//# sourceMappingURL=isPidRunning.js.map