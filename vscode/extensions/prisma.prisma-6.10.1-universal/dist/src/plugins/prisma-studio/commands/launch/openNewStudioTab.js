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
exports.openNewStudioTab = openNewStudioTab;
const vscode_1 = require("vscode");
const getStudioPageHtml_1 = require("./getStudioPageHtml");
const startStudioServer_1 = require("./startStudioServer");
/**
 * Opens Prisma Studio in a webview panel.
 * @param args - An object containing the database URL and extension context.
 */
function openNewStudioTab(args) {
    return __awaiter(this, void 0, void 0, function* () {
        const { server, url } = yield (0, startStudioServer_1.startStudioServer)(args);
        const panel = vscode_1.window.createWebviewPanel('studio', 'Studio', vscode_1.ViewColumn.One, {
            enableScripts: true,
            retainContextWhenHidden: true,
        });
        panel.webview.html = (0, getStudioPageHtml_1.getStudioPageHtml)({ serverUrl: url });
        panel.onDidDispose(() => {
            server.close();
            console.log(`Studio server has been closed (${url})`);
        });
    });
}
//# sourceMappingURL=openNewStudioTab.js.map