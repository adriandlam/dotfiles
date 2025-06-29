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
exports.pickWorkspace = void 0;
const vscode_1 = require("vscode");
const vscode_2 = require("vscode");
const handleCommandError_1 = require("./handleCommandError");
const pickWorkspace = (ppgRepository) => __awaiter(void 0, void 0, void 0, function* () {
    const workspaces = yield ppgRepository.getWorkspaces();
    const workspacesQuickPickItems = [
        ...workspaces.map((w) => ({ workspace: w, label: w.name, iconPath: new vscode_1.ThemeIcon('folder') })),
    ];
    const selectedItem = yield vscode_2.window.showQuickPick(workspacesQuickPickItems, {
        placeHolder: 'Select the workspace',
    });
    if (!selectedItem)
        throw new handleCommandError_1.CommandAbortError('Workspace is required');
    return selectedItem.workspace;
});
exports.pickWorkspace = pickWorkspace;
//# sourceMappingURL=pickWorkspace.js.map