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
exports.createLocalDatabase = createLocalDatabase;
const vscode_1 = require("vscode");
function createLocalDatabase(ppgRepository) {
    return __awaiter(this, void 0, void 0, function* () {
        const name = yield vscode_1.window.showInputBox({
            prompt: 'Enter your local database name',
            placeHolder: 'e.g., MyAwesomeProject',
            value: 'default',
        });
        yield ppgRepository.createLocalDatabase({ name: name !== null && name !== void 0 ? name : 'default' });
    });
}
//# sourceMappingURL=createLocalDatabase.js.map