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
exports.deployLocalDatabase = deployLocalDatabase;
exports.deployLocalDatabaseSalefy = deployLocalDatabaseSalefy;
const PrismaPostgresRepository_1 = require("../PrismaPostgresRepository");
const createRemoteDatabase_1 = require("./createRemoteDatabase");
const vscode_1 = require("vscode");
function deployLocalDatabase(ppgRepository, args) {
    return __awaiter(this, void 0, void 0, function* () {
        const { name, pid, url, running } = PrismaPostgresRepository_1.LocalDatabaseSchema.parse(args);
        if (running) {
            const confirmation = yield vscode_1.window.showInformationMessage('To deploy your local Prisma Postgres database, you will need to stop the database first. Proceed?', { modal: true }, 'Yes');
            if (confirmation !== 'Yes') {
                void vscode_1.window.showInformationMessage('Deployment cancelled.');
                return;
            }
            yield ppgRepository.stopLocalDatabase({ pid, url });
        }
        const createdDb = yield (0, createRemoteDatabase_1.createRemoteDatabaseSafely)(ppgRepository, undefined, { skipRefresh: true });
        if ((createdDb === null || createdDb === void 0 ? void 0 : createdDb.database) === undefined) {
            throw new Error('Unexpected error, no database was returned');
        }
        const { database: { connectionString }, project: { workspaceId, id: projectId }, } = createdDb;
        yield vscode_1.window.withProgress({
            location: vscode_1.ProgressLocation.Notification,
            title: `Deploying remote database...`,
        }, () => ppgRepository.deployLocalDatabase({ name, url: connectionString, projectId, workspaceId }));
        void vscode_1.window.showInformationMessage('Deployment was successful!');
    });
}
function deployLocalDatabaseSalefy(ppgRepository, args) {
    return __awaiter(this, void 0, void 0, function* () {
        return deployLocalDatabase(ppgRepository, args);
    });
}
//# sourceMappingURL=deployLocalDatabase.js.map