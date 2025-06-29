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
exports.launchStudio = exports.LaunchArgRemoteSchema = exports.LaunchArgLocalSchema = void 0;
const vscode_1 = require("vscode");
const zod_1 = require("zod");
const launch_1 = require("../../prisma-studio/commands/launch");
exports.LaunchArgLocalSchema = zod_1.z.object({
    type: zod_1.z.literal('local'),
    id: zod_1.z.string(),
    name: zod_1.z.string(),
    url: zod_1.z.string(),
    pid: zod_1.z.number(),
});
exports.LaunchArgRemoteSchema = zod_1.z.object({
    type: zod_1.z.literal('remote'),
    workspaceId: zod_1.z.string(),
    projectId: zod_1.z.string(),
    databaseId: zod_1.z.string(),
});
const LaunchArgSchema = zod_1.z.union([exports.LaunchArgLocalSchema, exports.LaunchArgRemoteSchema]);
const launchStudio = (_a) => __awaiter(void 0, [_a], void 0, function* ({ ppgRepository, context, args, }) {
    const database = LaunchArgSchema.parse(args);
    if (database.type === 'local') {
        yield ppgRepository.startLocalDatabase(database);
    }
    const connectionString = yield getConnectionString(ppgRepository, database);
    if (!connectionString)
        return;
    void (0, launch_1.launch)({ dbUrl: connectionString, context });
});
exports.launchStudio = launchStudio;
const getConnectionString = (ppgRepository, database) => __awaiter(void 0, void 0, void 0, function* () {
    if (database.type === 'local') {
        const localDatabases = yield ppgRepository.getLocalDatabases();
        return localDatabases.find((db) => db.id === database.id).url;
    }
    const connectionString = yield ppgRepository.getStoredRemoteDatabaseConnectionString(database);
    if (connectionString)
        return connectionString;
    const result = yield vscode_1.window.showInformationMessage(`Create Connection String`, {
        detail: `To open Studio with this database a connection string is required but no locally stored connection string was found.\n\nDo you want to create a new connection string?`,
        modal: true,
    }, { id: 'create', title: 'Create connection string', isCloseAffordance: false }, { id: 'cancel', title: 'Cancel', isCloseAffordance: true });
    if ((result === null || result === void 0 ? void 0 : result.id) !== 'create')
        return undefined;
    const createdConnectionString = yield vscode_1.window.withProgress({
        location: vscode_1.ProgressLocation.Notification,
        title: `Creating connection string...`,
    }, () => ppgRepository.createRemoteDatabaseConnectionString(database));
    return createdConnectionString;
});
//# sourceMappingURL=launchStudio.js.map