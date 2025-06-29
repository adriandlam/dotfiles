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
exports.getRemoteDatabaseConnectionString = void 0;
const vscode_1 = require("vscode");
const PrismaPostgresRepository_1 = require("../PrismaPostgresRepository");
const connectionStringMessage_1 = require("../shared-ui/connectionStringMessage");
const getRemoteDatabaseConnectionString = (ppgRepository, args) => __awaiter(void 0, void 0, void 0, function* () {
    if (!(0, PrismaPostgresRepository_1.isRemoteDatabase)(args))
        throw new Error('Invalid arguments');
    const connectionString = yield ppgRepository.getStoredRemoteDatabaseConnectionString({
        workspaceId: args.workspaceId,
        projectId: args.projectId,
        databaseId: args.id,
    });
    if (connectionString) {
        void (0, connectionStringMessage_1.presentConnectionString)({
            connectionString,
            type: 'connectionStringDisplay',
        });
        return;
    }
    const result = yield vscode_1.window.showInformationMessage(`Create Connection String`, {
        detail: `No locally stored connection string found for remote database ${args.name}.\n\nDo you want to create a new connection string?`,
        modal: true,
    }, { id: 'create', title: 'Create connection string', isCloseAffordance: false }, { id: 'cancel', title: 'Cancel', isCloseAffordance: true });
    if ((result === null || result === void 0 ? void 0 : result.id) === 'cancel')
        return;
    const createdConnectionString = yield vscode_1.window.withProgress({
        location: vscode_1.ProgressLocation.Notification,
        title: `Creating connection string...`,
    }, () => ppgRepository.createRemoteDatabaseConnectionString({
        workspaceId: args.workspaceId,
        projectId: args.projectId,
        databaseId: args.id,
    }));
    void (0, connectionStringMessage_1.presentConnectionString)({
        connectionString: createdConnectionString,
        type: 'connectionStringCreated',
    });
});
exports.getRemoteDatabaseConnectionString = getRemoteDatabaseConnectionString;
//# sourceMappingURL=getRemoteDatabaseConnectionString.js.map