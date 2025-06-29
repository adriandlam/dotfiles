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
exports.deleteRemoteDatabase = void 0;
const vscode_1 = require("vscode");
const vscode_2 = require("vscode");
const PrismaPostgresRepository_1 = require("../PrismaPostgresRepository");
const deleteRemoteDatabase = (ppgRepository, args) => __awaiter(void 0, void 0, void 0, function* () {
    if (!(0, PrismaPostgresRepository_1.isRemoteDatabase)(args))
        throw new Error('Invalid arguments');
    const confirmDeleteResult = yield vscode_2.window.showWarningMessage(`Are you sure you want to delete database '${args.name}'?`, { modal: true }, { title: 'Delete' }, { title: 'Cancel', isCloseAffordance: true });
    if ((confirmDeleteResult === null || confirmDeleteResult === void 0 ? void 0 : confirmDeleteResult.title) !== 'Delete')
        return;
    yield vscode_2.window.withProgress({
        location: vscode_1.ProgressLocation.Notification,
        title: `Deleting database...`,
    }, () => ppgRepository.deleteRemoteDatabase({
        workspaceId: args.workspaceId,
        projectId: args.projectId,
        id: args.id,
    }));
    void vscode_2.window.showInformationMessage(`Database deleted`);
});
exports.deleteRemoteDatabase = deleteRemoteDatabase;
//# sourceMappingURL=deleteRemoteDatabase.js.map