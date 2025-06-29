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
exports.presentConnectionString = void 0;
const vscode_1 = require("vscode");
const TITLE_COPY = {
    databaseCreated: 'Database created',
    connectionStringCreated: 'Connection string created',
    connectionStringDisplay: 'Connection string',
};
const presentConnectionString = (_a) => __awaiter(void 0, [_a], void 0, function* ({ connectionString, type, }) {
    const truncatedConnectionString = `${connectionString.slice(0, 60)}...`;
    yield vscode_1.window.showInformationMessage(TITLE_COPY[type], {
        detail: `Connection string:\n${truncatedConnectionString}\n\nWe store this connection string securely in VS Code Secret Storage on this machine. We recommend you store it in another secure place with your application configuration, too.`,
        modal: true,
    }, { title: 'Copy connection string', isCloseAffordance: true });
    yield vscode_1.env.clipboard.writeText(connectionString);
});
exports.presentConnectionString = presentConnectionString;
//# sourceMappingURL=connectionStringMessage.js.map