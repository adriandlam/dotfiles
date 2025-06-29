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
exports.handleCommandError = exports.CommandAbortError = void 0;
const vscode_1 = require("vscode");
class CommandAbortError extends Error {
    constructor(message) {
        super(message);
    }
}
exports.CommandAbortError = CommandAbortError;
const handleCommandError = (cmdTitle, cmd) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        return yield cmd();
    }
    catch (error) {
        if (error instanceof CommandAbortError) {
            void vscode_1.window.showInformationMessage(`${cmdTitle} aborted: ${error.message}`);
        }
        else if (error instanceof Error) {
            void vscode_1.window.showErrorMessage(`${cmdTitle} failed: ${error.message}`);
        }
        else {
            void vscode_1.window.showErrorMessage(`${cmdTitle} failed: An unknown error occurred`);
        }
        return null;
    }
});
exports.handleCommandError = handleCommandError;
//# sourceMappingURL=handleCommandError.js.map