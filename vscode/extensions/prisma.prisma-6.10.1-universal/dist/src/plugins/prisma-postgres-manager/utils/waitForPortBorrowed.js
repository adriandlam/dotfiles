"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.waitForPortBorrowed = waitForPortBorrowed;
const net_1 = require("net");
const promises_1 = require("node:timers/promises");
function waitForPortBorrowed(port_1) {
    return __awaiter(this, arguments, void 0, function* (port, attemptsMade = 0) {
        if (attemptsMade >= 10) {
            throw new Error(`Port ${port} was not borrowed`);
        }
        yield (0, promises_1.setTimeout)(attemptsMade * 100);
        yield new Promise((resolve, reject) => {
            const socket = (0, net_1.connect)(port, '127.0.0.1', resolve);
            socket.once('error', () => (socket.destroy(), reject()));
            socket.once('connect', () => (socket.destroy(), resolve()));
        }).catch(() => waitForPortBorrowed(port, attemptsMade + 1));
    });
}
//# sourceMappingURL=waitForPortBorrowed.js.map